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
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { builtinModules } from "node:module";
import { execFileSync } from "node:child_process";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../../..");
const BUILTINS = new Set(builtinModules);

// @raycast/api exports that are TYPE-ONLY (interfaces / type-namespaces with no runtime value form).
// Extensions import them in mixed `import { List, LaunchProps }` statements, but they only ever appear
// in type position, so TS/esbuild erases them at runtime — a missing runtime export in our shim is
// harmless and must not drive the compatibility verdict to "needs-work". (Symbols that are BOTH a type
// and a runtime value — e.g. Toast, which carries Toast.Style — are deliberately NOT listed here.)
const TYPE_ONLY_API = new Set<string>([
  "LaunchProps",
  "Tool",
  "LaunchContext",
  "PreferenceValues",
  "Application",
  "FileSystemItem",
]);

// Node builtins the sandbox denies by default but for which Invoke provides a curated, read-only shim
// (see runtime/node-host/src/os-safe.mjs + deny-loader.mjs), so they should NOT count as "denied".
const CURATED_BUILTINS = new Set<string>(["os"]);

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
  // optional default import (`Foo,`), optional `type` keyword, then the named braces
  const re = new RegExp(`import\\s+(?:[\\w$]+\\s*,\\s*)?(type\\s+)?\\{([^}]*)\\}\\s+from\\s+["']${module}["']`, "g");
  let m: RegExpExecArray | null;
  while ((m = re.exec(code))) {
    if (m[1]) continue; // `import type { … }` — all type-only, erased at runtime (not fatal)
    for (const raw of m[2].split(",")) {
      const t = raw.trim();
      if (/^type\s/.test(t)) continue; // inline `type X` — a type-only specifier, erased
      const name = t.split(/\s+as\s+/)[0].trim();
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

/** Parse a github.com repo or subfolder URL (incl. raycast/extensions monorepo `.../tree/<branch>/<sub>`). */
function parseGitHubURL(u: string): { owner: string; repo: string; branch?: string; subpath?: string } | null {
  let m = u.match(/^git@github\.com:([^/]+)\/(.+?)(?:\.git)?\/?$/i);
  if (m) return { owner: m[1], repo: m[2] };
  m = u.match(/^https?:\/\/github\.com\/([^/]+)\/([^/]+?)(?:\.git)?(?:\/(?:tree|blob)\/([^/]+)\/(.+?))?\/?$/i);
  if (m) return { owner: m[1], repo: m[2], branch: m[3], subpath: m[4] };
  return null;
}

/** Resolve the import source to a local dir: clone a github URL (shallow + sparse for a subfolder) or
 *  use the path as-is. git clone does NOT run repo hooks/scripts, so cloning itself executes no code;
 *  the cloned source is then scanned + copied + its deps installed with --ignore-scripts (gated). */
async function resolveSource(arg: string, quiet: boolean): Promise<{ dir: string; cleanup: () => void }> {
  if (!/^(https?:\/\/|git@)/i.test(arg)) return { dir: path.resolve(arg), cleanup: () => {} };
  const g = parseGitHubURL(arg) ?? die(`Unsupported URL — expected a github.com repo or subfolder: ${arg}`);
  if (g.subpath && g.subpath.split("/").includes("..")) die(`Invalid path in URL: ${g.subpath}`);
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "invoke-import-"));
  const repoURL = `https://github.com/${g.owner}/${g.repo}.git`;
  const run = (args: string[]) => execFileSync("git", args, { stdio: quiet ? ["ignore", "ignore", "pipe"] : "inherit" });
  try {
    const branchArgs = g.branch ? ["--branch", g.branch] : [];
    if (g.subpath) {
      run(["clone", "--depth", "1", "--filter=blob:none", "--sparse", ...branchArgs, repoURL, tmp]);
      run(["-C", tmp, "sparse-checkout", "set", g.subpath]);
      const dir = path.join(tmp, g.subpath);
      if (!fs.existsSync(path.join(dir, "package.json"))) die(`No extension (package.json) at "${g.subpath}" in ${g.owner}/${g.repo}`);
      return { dir, cleanup: () => fs.rmSync(tmp, { recursive: true, force: true }) };
    }
    run(["clone", "--depth", "1", ...branchArgs, repoURL, tmp]);
    if (!fs.existsSync(path.join(tmp, "package.json"))) die(`No package.json at the repo root of ${g.owner}/${g.repo} — for a monorepo, use the subfolder URL (…/tree/<branch>/<path>)`);
    return { dir: tmp, cleanup: () => fs.rmSync(tmp, { recursive: true, force: true }) };
  } catch (e) {
    fs.rmSync(tmp, { recursive: true, force: true });
    const msg = (e as { stderr?: Buffer }).stderr?.toString().trim() || (e as Error).message;
    die(`git clone failed: ${msg}`);
  }
}

async function main(): Promise<void> {
  const args = process.argv.slice(2);
  const checkOnly = args.includes("--check");
  const jsonOut = args.includes("--json");
  // --trusted: the user intends to run this extension UNSANDBOXED, so denied builtins (fs,
  // child_process, …) are actually available — recompute the verdict accordingly.
  const trusted = args.includes("--trusted");
  const nameIdx = args.indexOf("--name");
  const nameFlag = args.find((a) => a.startsWith("--name="))?.split("=")[1] ?? (nameIdx >= 0 ? args[nameIdx + 1] : undefined);
  const nameValueIdx = nameIdx >= 0 ? nameIdx + 1 : -1; // -1 → don't exclude anything
  const positional = args.filter((a, i) => !a.startsWith("--") && i !== nameValueIdx); // exclude --name's value
  // Source is a local folder OR a github.com URL (repo / monorepo subfolder) — clone the latter.
  const { dir: src, cleanup } = await resolveSource(
    positional[0] ?? die("usage: import <sourceDir|githubURL> [--name <id>] [--check]"), jsonOut);
  process.on("exit", cleanup); // remove any temp clone, even on die()

  const manifest = readManifest(src);
  // For a monorepo subfolder the basename is the extension dir; manifest.name is preferred.
  // The id becomes a SEGMENT of the host command id "ext.<id>.<command>" and of the per-extension
  // trust/consent grant key, both of which split on ".". A dot in the id would therefore (a) make the
  // launcher's grant-key derivation disagree with what was stored, silently dropping trust, and worse
  // (b) let two distinct extensions whose ids share a pre-dot prefix collapse to ONE grant key — a
  // later, untrusted extension could inherit an earlier one's trust. So "." is NOT allowed here.
  const id = (nameFlag ?? manifest.name ?? path.basename(src))
    .replace(/[^a-zA-Z0-9_-]/g, "-")
    .replace(/-+/g, "-")
    .replace(/^-+|-+$/g, "") || "extension";
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
    // A symbol in a MIXED import (`import { List, LaunchProps } from "@raycast/api"`) reads as a value
    // import syntactically, but if it's a TYPE_ONLY_API symbol it's only ever used in type position and
    // esbuild/tsx erases it at runtime — so a missing runtime export is harmless, not blocking. (The
    // `import type { … }` / inline `type X` cases are already filtered inside importedSymbols.)
    for (const s of importedSymbols(code, "@raycast/api")) {
      if (!api.has(s) && !TYPE_ONLY_API.has(s)) missingApi.add(s);
    }
    for (const s of importedSymbols(code, "@raycast/utils")) if (!utils.has(s)) missingUtils.add(s);
    for (const spec of specifiers(code)) {
      const bare = spec.startsWith("node:") ? spec.slice(5) : spec;
      if (BUILTINS.has(bare) && !SAFE_BUILTINS.has(bare) && !CURATED_BUILTINS.has(bare)) deniedBuiltins.add(bare);
    }
  }

  const commandInfo = commands.map((c) => {
    const mode = c.mode ?? "view";
    const entry = [".tsx", ".ts", ".jsx", ".js"].map((e) => `src/${c.name}${e}`).find((rel) => fs.existsSync(path.join(src, rel)));
    if (!entry) unresolvedEntries++;
    return { name: c.name, title: c.title ?? c.name, mode, entryFound: !!entry };
  });

  const blocking = missingApi.size > 0 || unresolvedEntries > 0;
  // A TRUSTED extension runs unsandboxed, so denied builtins are actually available — they no longer
  // degrade the verdict. Missing/unresolved APIs still block regardless of trust (they don't exist).
  const verdict = blocking
    ? "needs-work"
    : (deniedBuiltins.size > 0 && !trusted)
      ? "degraded"
      : "runnable";

  // Install (unless --check): copy the source into imported/<id>/ (resolves @raycast/api from the
  // repo node_modules), with a per-file automatic-JSX pragma codemod so it needn't `import React`.
  let installed = false;
  let destRel = "";
  let installedDeps: string[] = [];
  let depInstallError = "";
  if (!checkOnly) {
    const dest = path.join(ROOT, "imported", id);
    fs.rmSync(dest, { recursive: true, force: true });
    fs.mkdirSync(dest, { recursive: true });
    for (const entry of ["package.json", "src", "assets", "icon.png"]) {
      const from = path.join(src, entry);
      if (fs.existsSync(from)) fs.cpSync(from, path.join(dest, entry), { recursive: true });
    }
    const PRAGMA = "/** @jsxRuntime automatic @jsxImportSource react */\n";
    const codemod = (d: string) => {
      for (const e of fs.readdirSync(d, { withFileTypes: true })) {
        const p = path.join(d, e.name);
        if (e.isDirectory()) codemod(p);
        else if (/\.(tsx|jsx)$/.test(e.name)) {
          const code = fs.readFileSync(p, "utf8");
          if (code.includes("@jsxImportSource")) continue;
          if (code.startsWith("#!")) {
            const nl = code.indexOf("\n") + 1; // a shebang must stay on line 1 — insert after it
            fs.writeFileSync(p, code.slice(0, nl) + PRAGMA + code.slice(nl));
          } else {
            fs.writeFileSync(p, PRAGMA + code);
          }
        }
      }
    };
    if (fs.existsSync(path.join(dest, "src"))) codemod(path.join(dest, "src"));
    installed = true;
    destRel = path.relative(ROOT, dest);

    // Auto-install the extension's third-party npm deps into the repo node_modules (skip the ones we
    // shim: @raycast/api, @raycast/utils, @invoke/*, and React which the repo already provides).
    //
    // SECURITY: this runs `npm install` from an UNREVIEWED, user-chosen extension's package.json.
    //   • Only registry packages with a valid name + plain semver range are installed — git/url/file/
    //     link/alias version sources (an install-source injection that fetches arbitrary code) are
    //     rejected outright.
    //   • `--ignore-scripts` so no pre/post-install lifecycle script can execute at import time.
    //   • `--` so a package name can never be parsed as an npm flag.
    const NAME_RE = /^(@[a-z0-9-~][a-z0-9-._~]*\/)?[a-z0-9-~][a-z0-9-._~]*$/;
    const safeVersion = (v: unknown): boolean => {
      if (typeof v !== "string") return false;
      const t = v.trim();
      if (t === "*" || t === "latest") return true;
      if (/[/:]/.test(t)) return false; // protocols, github:owner/repo, owner/repo, npm: aliases
      if (/\b(git|https?|ssh|file|link|workspace|npm)\b/i.test(t)) return false;
      return /^[\^~>=< ]*\d[\w.\-+ |x*]*$/.test(t); // semver-ish range
    };
    const allDeps = (manifest as { dependencies?: Record<string, string> }).dependencies ?? {};
    const rejected: string[] = [];
    const toInstall = Object.keys(allDeps).filter((d) => {
      if (d.startsWith("@raycast/") || d.startsWith("@invoke/") || d === "react" || d === "react-dom") return false;
      if (!NAME_RE.test(d) || !safeVersion(allDeps[d])) { rejected.push(d); return false; }
      return true;
    });
    if (rejected.length) depInstallError = `Skipped unsafe dependency specs: ${rejected.join(", ")}.`;
    const missingDeps = toInstall.filter((d) => !fs.existsSync(path.join(ROOT, "node_modules", d)));
    if (missingDeps.length) {
      const present = () => missingDeps.filter((d) => fs.existsSync(path.join(ROOT, "node_modules", d)));
      try {
        const specs = missingDeps.map((d) => `${d}@${allDeps[d].trim()}`);
        execFileSync("npm", ["install", "--no-save", "--ignore-scripts", "--", ...specs], { cwd: ROOT, stdio: jsonOut ? "ignore" : "inherit" });
        installedDeps = present();
      } catch (e) {
        installedDeps = present();
        const msg = (e as Error)?.message ?? String(e);
        depInstallError = `${depInstallError ? depInstallError + " " : ""}Could not install ${missingDeps.join(", ")}: ${msg}`;
      }
    }
  }

  if (jsonOut) {
    // Structured report for the in-app Import UI (the only thing on stdout, so it parses cleanly).
    console.log(JSON.stringify({
      id,
      title: manifest.title ?? id,
      commands: commandInfo,
      missingApi: [...missingApi],
      missingUtils: [...missingUtils],
      deniedBuiltins: [...deniedBuiltins],
      blocking,
      verdict,
      trusted,
      installed,
      dest: destRel,
      installedDeps,
      depInstallError,
    }));
    return;
  }

  console.log(`\n▸ ${manifest.title ?? id}  (${id})`);
  console.log(`  source: ${path.relative(process.cwd(), src)}`);
  console.log(`  commands:`);
  for (const c of commandInfo) {
    const note = c.entryFound ? (c.mode === "view" ? "✓ renders" : `${c.mode} (limited)`) : "✗ entry not found";
    console.log(`    • ${c.name} — ${c.title} [${c.mode}] ${note}`);
  }
  console.log(`\n  compatibility:`);
  console.log(`    @raycast/api    : ${missingApi.size === 0 ? "all imports supported ✓" : "MISSING (fatal — fails module load): " + [...missingApi].join(", ")}`);
  console.log(`    @raycast/utils  : ${missingUtils.size === 0 ? "ok ✓" : "MISSING: " + [...missingUtils].join(", ")}`);
  console.log(`    sandbox         : ${deniedBuiltins.size === 0 ? "no denied builtins ✓" : trusted ? "uses " + [...deniedBuiltins].join(", ") + " — available (TRUSTED: runs unsandboxed)" : "uses denied builtins (need a host capability): " + [...deniedBuiltins].join(", ")}`);
  console.log(`    verdict         : ${verdict === "needs-work" ? "⚠️  needs work before it runs" : verdict === "degraded" ? "loads; degraded where it touches denied builtins" : "👍 looks runnable"}`);
  if (installed) {
    console.log(`\n✓ installed to ${destRel}`);
    console.log(`  run headless:  npm run dev:ext imported/${id}` + (commands[0] ? ` -- --command=${commands[0].name}` : ""));
    console.log(`  in the app:    relaunch — it appears in the Extensions group\n`);
  } else {
    console.log(`\n(check only — not installed)\n`);
  }
}

main().catch((e: unknown) => die(String(e)));
