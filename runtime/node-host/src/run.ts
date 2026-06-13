/**
 * Manifest-driven extension runner (PLAN.md §5.1/§5.6) — the dev counterpart of `invoke dev`.
 *
 * Reads an extension's package.json, resolves a command (`commands[].name` → `src/<name>.tsx`),
 * builds preferences from the manifest defaults, launches it through the real host (ExtensionProcess),
 * and fulfils the allowlisted host capabilities with Node implementations (open / clipboard / toast /
 * hud / localStorage / preferences). Prints the rendered view tree so a real extension can be exercised
 * end-to-end without Xcode.
 *
 *   tsx run.ts <extensionDir> [--command=<name>] [--query=<text>] [--activate-first] [--open]
 */
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { ExtensionProcess } from "./supervisor.ts";
import { renderTree, type ViewTree, type VNode } from "./viewmodel.ts";

interface Manifest {
  name?: string;
  title?: string;
  commands?: Array<{ name: string; title?: string; mode?: string }>;
  preferences?: Array<{ name: string; default?: unknown }>;
}

function readManifest(dir: string): Manifest {
  return JSON.parse(fs.readFileSync(path.join(dir, "package.json"), "utf8")) as Manifest;
}

/** Map a command name to its entry file (Raycast convention: src/<name>.<ext>). */
function resolveEntry(dir: string, name: string): string {
  for (const ext of [".tsx", ".ts", ".jsx", ".js"]) {
    const p = path.join(dir, "src", name + ext);
    if (fs.existsSync(p)) return p;
  }
  throw new Error(`no entry for command "${name}" (looked for ${dir}/src/${name}.{tsx,ts,jsx,js})`);
}

function preferenceDefaults(prefs: Manifest["preferences"]): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  for (const p of prefs ?? []) if (p.default !== undefined) out[p.name] = p.default;
  return out;
}

function collect(node: VNode, type: string, out: VNode[] = []): VNode[] {
  if (node.type === type) out.push(node);
  for (const c of node.children) collect(c, type, out);
  return out;
}

const delay = (ms: number) => new Promise((r) => setTimeout(r, ms));

/** Node-side fulfilment of the host capability allowlist (the macOS app does this in Swift). */
function devCapabilities(opts: { preferences: Record<string, unknown>; storePath: string; reallyOpen: boolean }) {
  let store: Record<string, unknown> = {};
  try {
    store = JSON.parse(fs.readFileSync(opts.storePath, "utf8")) as Record<string, unknown>;
  } catch {
    /* fresh store */
  }
  const persist = () => {
    try {
      fs.writeFileSync(opts.storePath, JSON.stringify(store));
    } catch {
      /* best-effort */
    }
  };
  const opened: string[] = [];
  const toasts: Array<Record<string, unknown>> = [];
  let lastCopy = "";

  const handler = async (method: string, raw: unknown): Promise<unknown> => {
    const params = (raw ?? {}) as Record<string, any>;
    switch (method) {
      case "open": {
        const target = String(params.target ?? "");
        opened.push(target);
        console.log(`  ↗ open ${target}`);
        if (opts.reallyOpen) {
          const { spawn } = await import("node:child_process");
          spawn("/usr/bin/open", [target], { stdio: "ignore", detached: true }).unref();
        }
        return null;
      }
      case "clipboard.copy":
        lastCopy = String(params.content ?? "");
        console.log(`  ⧉ copied ${JSON.stringify(lastCopy).slice(0, 60)}`);
        return null;
      case "clipboard.paste":
        return null;
      case "clipboard.readText":
        return lastCopy;
      case "toast.show":
        toasts.push(params);
        console.log(`  ◔ toast [${params.style}] ${params.title}${params.message ? " — " + params.message : ""}`);
        return null;
      case "hud.show":
        console.log(`  ◔ hud ${params.title}`);
        return null;
      case "window.close":
        return null;
      case "preferences.get":
        return opts.preferences;
      case "localStorage.getItem":
        return store[params.key];
      case "localStorage.setItem":
        store[params.key] = params.value;
        persist();
        return null;
      case "localStorage.removeItem":
        delete store[params.key];
        persist();
        return null;
      case "localStorage.clear":
        store = {};
        persist();
        return null;
      case "localStorage.allItems":
        return { ...store };
      case "executeSQL": {
        // Dev-only mirror of the Swift host capability: copy the (WAL) db + sidecars to temp and query
        // the copy via node:sqlite, so `npm run dev:ext` can exercise useSQL extensions headlessly.
        const dbPath = String(params.db ?? "");
        const query = String(params.query ?? "");
        if (!dbPath || !query) return [];
        const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "invoke-dev-sql-"));
        try {
          const { DatabaseSync } = (await import("node:sqlite")) as {
            DatabaseSync: new (p: string) => { prepare: (q: string) => { all: () => unknown[] }; close: () => void };
          };
          const dest = path.join(tmp, path.basename(dbPath));
          fs.copyFileSync(dbPath, dest);
          for (const s of ["-wal", "-shm"]) if (fs.existsSync(dbPath + s)) fs.copyFileSync(dbPath + s, dest + s);
          const db = new DatabaseSync(dest);
          const rows = db.prepare(query).all();
          db.close();
          return rows;
        } catch (e) {
          console.error("  [dev executeSQL] error:", (e as Error).message);
          return [];
        } finally {
          fs.rmSync(tmp, { recursive: true, force: true });
        }
      }
      default:
        return null;
    }
  };

  return { handler, opened, toasts, get lastCopy() { return lastCopy; } };
}

/** Run the host-side equivalent of activating an item's first action (what a keypress does). */
async function activateFirstItem(tree: ViewTree, proc: ExtensionProcess, caps: ReturnType<typeof devCapabilities>): Promise<void> {
  const item = collect(tree.root, "list-item")[0] ?? collect(tree.root, "grid-item")[0];
  if (!item) {
    console.log("  (no item to activate)");
    return;
  }
  const action = collect(item, "action")[0];
  if (!action) {
    console.log("  (selected item has no actions)");
    return;
  }
  const variant = action.props.variant as string | undefined;
  const handlerRef = (action.props.onAction as { __handler?: string } | undefined)?.__handler;
  console.log(`▶ activate "${item.props.title ?? ""}" → action ${variant ?? "default"}`);
  if (variant === "open-in-browser") await caps.handler("open", { target: action.props.url });
  else if (variant === "copy") await caps.handler("clipboard.copy", { content: action.props.content });
  else if (variant === "paste") await caps.handler("clipboard.paste", { content: action.props.content });
  else if (handlerRef) proc.invoke(handlerRef, []);
}

async function main(): Promise<void> {
  const args = process.argv.slice(2);
  const dir = path.resolve(args.find((a) => !a.startsWith("--")) ?? ".");
  const flag = (name: string): string | boolean | undefined => {
    const a = args.find((x) => x === `--${name}` || x.startsWith(`--${name}=`));
    if (!a) return undefined;
    return a.includes("=") ? a.slice(a.indexOf("=") + 1) : true;
  };

  const manifest = readManifest(dir);
  const commandName = (flag("command") as string) || manifest.commands?.[0]?.name;
  if (!commandName) throw new Error(`no command in manifest ${dir}/package.json`);
  const entry = resolveEntry(dir, commandName);
  const preferences = preferenceDefaults(manifest.preferences);
  const caps = devCapabilities({
    preferences,
    storePath: path.join(os.tmpdir(), `invoke-localstorage-${manifest.name ?? "ext"}.json`),
    reallyOpen: flag("open") === true,
  });

  console.log(`▶ ${manifest.title ?? manifest.name ?? "extension"}  ·  command "${commandName}"  ·  ${path.relative(process.cwd(), entry)}`);
  if (Object.keys(preferences).length) console.log(`  preferences: ${JSON.stringify(preferences)}`);

  const proc = new ExtensionProcess(entry, commandName, preferences, caps.handler);
  let latest: ViewTree = proc.tree;
  proc.on("commit", (_c: number, t: ViewTree) => (latest = t));
  proc.on("log", (m) => console.log(`  [ext ${m.level}]`, ...m.args));
  proc.on("denied", (method: string) => console.log(`  ⛔ denied ${method}`));

  await new Promise<void>((res) => proc.once("ready", () => res()));

  const query = flag("query");
  if (typeof query === "string") proc.setSearchText(query);

  await delay(2600); // let async hooks (useFetch) resolve and re-render
  console.log(`\n${"─".repeat(8)} rendered view ${"─".repeat(28)}`);
  console.log(renderTree(latest.root));

  if (flag("activate-first")) {
    console.log(`\n${"─".repeat(8)} activate ${"─".repeat(32)}`);
    await activateFirstItem(latest, proc, caps);
    await delay(150);
  }

  console.log(`\n${"─".repeat(8)} summary ${"─".repeat(33)}`);
  console.log(`items: ${collect(latest.root, "list-item").length} · opened: ${JSON.stringify(caps.opened)} · toasts: ${caps.toasts.length} · lastCopy: ${JSON.stringify(caps.lastCopy)}`);
  proc.kill();
  await delay(50);
  process.exit(0);
}

main().catch((e: unknown) => {
  console.error("run failed:", e);
  process.exit(1);
});
