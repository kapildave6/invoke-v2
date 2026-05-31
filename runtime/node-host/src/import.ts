/**
 * `invoke import` (PLAN.md §5.6) — bring an existing @raycast/api extension's SOURCE into Invoke.
 *
 *   tsx import.ts <sourceDir> [--name <id>] [--check]
 *
 * Because our compat package is literally named `@raycast/api`, a source extension's
 * `import … from "@raycast/api"` resolves to our shim once the extension lives under the repo (Node
 * resolves bare specifiers up to the repo's node_modules). So importing is: (1) a COMPATIBILITY SCAN
 * that diffs the symbols the extension imports from @raycast/api / @raycast/utils against what our
 * shim actually exports — any unknown NAMED import is fatal (ESM fails the whole module load) — and
 * flags sandbox-denied node builtins; (2) copy the source into `imported/<name>/`, where the app
 * discovers it. `--check` does the scan only.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { builtinModules } from "node:module";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../../..");
const BUILTINS = new Set(builtinModules);

interface Manifest {
  name?: string;
  title?: string;
  commands?: Array<{ name: string; title?: string; mode?: string }>;
  preferences?: unknown[];
}

function die(msg: string): never {
  console.error(`✗ ${msg}`);
  process.exit(1);
}

function readManifest(dir: string): Manifest {
  const p = path.join(dir, "package.json");
  if (!fs.existsSync(p)) die(`no package.json in ${dir}`);
  try {
    return JSON.parse(fs.readFileSync(p, "utf8")) as Manifest;
  } catch (e) {
    die(`invalid package.json: ${String(e)}`);
  }
}

function sourceFiles(dir: string): string[] {
  const out: string[] = [];
  const walk = (d: string) => {
    if (!fs.existsSync(d)) return;
    for (const e of fs.readdirSync(d, { withFileTypes: true })) {
      const p = path.join(d, e.name);
      if (e.isDirectory()) {
        if (e.name !== "node_modules") walk(p);
      } else if (/\.(tsx?|jsx?)$/.test(e.name)) out.push(p);
    }
  };
  walk(path.join(dir, "src"));
  return out;
}

/** Named imports of `module` across the code (handles `import { A, B as C, type D }`). */
function importedSymbols(code: string, module: string): Set<string> {
  const out = new Set<string>();
  const re = new RegExp(`import\\s+(?:type\\s+)?\\{([^}]*)\\}\\s+from\\s+["']${module}["']`, "g");
  let m: RegExpExecArray | null;
  while ((m = re.exec(code))) {
    for (const raw of m[1].split(",")) {
      const name = raw.trim().replace(/^type\s+/, "").split(/\s+as\s+/)[0].trim();
      if (name) out.add(name);
    }
  }
  return out;
}

/** Bare module specifiers imported/required anywhere in the code. */
function specifiers(code: string): Set<string> {
  const out = new Set<string>();
  const patterns = [/from\s+["']([^"']+)["']/g, /require\(\s*["']([^"']+)["']\)/g, /import\(\s*["']([^"']+)["']\)/g];
  for (const re of patterns) {
    let m: RegExpExecArray | null;
    while ((m = re.exec(code))) out.add(m[1]);
  }
  return out;
}

async function main(): Promise<void> {
  const args = process.argv.slice(2);
  const positional = args.filter((a) => !a.startsWith("--"));
  const checkOnly = args.includes("--check");
  const nameFlag = args.find((a) => a.startsWith("--name="))?.split("=")[1];
  const src = path.resolve(positional[0] ?? die("usage: import <sourceDir> [--name <id>] [--check]"));

  const manifest = readManifest(src);
  const id = (nameFlag ?? manifest.name ?? path.basename(src)).replace(/[^a-zA-Z0-9._-]/g, "-");
  const commands = manifest.commands ?? [];

  // What our shim actually provides (introspected from the real exports).
  const api = new Set(Object.keys(await import("@invoke/api")));
  const utils = new Set(Object.keys(await import("@invoke/utils")));
  const SAFE_BUILTINS = new Set<string>(
    JSON.parse(fs.readFileSync(path.join(ROOT, "runtime/node-host/src/safe-builtins.json"), "utf8")),
  );

  const files = sourceFiles(src);
  const missingApi = new Set<string>();
  const missingUtils = new Set<string>();
  const deniedBuiltins = new Set<string>();
  let unresolvedEntries = 0;

  for (const f of files) {
    const code = fs.readFileSync(f, "utf8");
    for (const s of importedSymbols(code, "@raycast/api")) if (!api.has(s)) missingApi.add(s);
    for (const s of importedSymbols(code, "@raycast/utils")) if (!utils.has(s)) missingUtils.add(s);
    for (const spec of specifiers(code)) {
      const bare = spec.startsWith("node:") ? spec.slice(5) : spec;
      if (BUILTINS.has(bare) && !SAFE_BUILTINS.has(bare)) deniedBuiltins.add(bare);
    }
  }

  console.log(`\n▸ ${manifest.title ?? id}  (${id})`);
  console.log(`  source: ${path.relative(process.cwd(), src)}`);
  console.log(`  commands:`);
  for (const c of commands) {
    const mode = c.mode ?? "view";
    const entry = [".tsx", ".ts", ".jsx", ".js"].map((e) => `src/${c.name}${e}`).find((rel) => fs.existsSync(path.join(src, rel)));
    const note = entry ? (mode === "view" ? "✓ renders" : `${mode} (limited)`) : "✗ entry not found";
    if (!entry) unresolvedEntries++;
    console.log(`    • ${c.name} — ${c.title ?? c.name} [${mode}] ${note}`);
  }

  const blocking = missingApi.size > 0 || unresolvedEntries > 0;
  console.log(`\n  compatibility:`);
  console.log(`    @raycast/api    : ${missingApi.size === 0 ? "all imports supported ✓" : "MISSING (fatal — fails module load): " + [...missingApi].join(", ")}`);
  console.log(`    @raycast/utils  : ${missingUtils.size === 0 ? "ok ✓" : "MISSING: " + [...missingUtils].join(", ")}`);
  console.log(`    sandbox         : ${deniedBuiltins.size === 0 ? "no denied builtins ✓" : "uses denied builtins (need a host capability): " + [...deniedBuiltins].join(", ")}`);
  console.log(`    verdict         : ${blocking ? "⚠️  needs work before it runs" : deniedBuiltins.size ? "loads; degraded where it touches denied builtins" : "👍 looks runnable"}`);

  if (checkOnly) {
    console.log(`\n(check only — not installed)\n`);
    return;
  }

  // Install: copy the source into imported/<name>/ (resolves @raycast/api from the repo node_modules).
  const dest = path.join(ROOT, "imported", id);
  fs.rmSync(dest, { recursive: true, force: true });
  fs.mkdirSync(dest, { recursive: true });
  for (const entry of ["package.json", "src", "assets", "icon.png"]) {
    const from = path.join(src, entry);
    if (fs.existsSync(from)) fs.cpSync(from, path.join(dest, entry), { recursive: true });
  }
  // Codemod: prepend an automatic-JSX pragma to each source file so it needn't `import React` (like a
  // real extension). esbuild/tsx honor the pragma per-file, independent of which tsconfig covers
  // imported/ (the root tsconfig's `include` does not, so it'd otherwise fall back to classic JSX).
  const PRAGMA = "/** @jsxRuntime automatic @jsxImportSource react */\n";
  const codemod = (d: string) => {
    for (const e of fs.readdirSync(d, { withFileTypes: true })) {
      const p = path.join(d, e.name);
      if (e.isDirectory()) codemod(p);
      else if (/\.(tsx|jsx)$/.test(e.name)) {
        const code = fs.readFileSync(p, "utf8");
        if (!code.includes("@jsxImportSource")) fs.writeFileSync(p, PRAGMA + code);
      }
    }
  };
  if (fs.existsSync(path.join(dest, "src"))) codemod(path.join(dest, "src"));
  console.log(`\n✓ installed to ${path.relative(process.cwd(), dest)}`);
  console.log(`  run headless:  npm run dev:ext imported/${id}` + (commands[0] ? ` -- --command=${commands[0].name}` : ""));
  console.log(`  in the app:    relaunch — it appears in the Extensions group\n`);
}

main().catch((e: unknown) => die(String(e)));
