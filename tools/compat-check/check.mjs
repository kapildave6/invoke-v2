#!/usr/bin/env node
// Invoke v2 — Raycast extension compatibility checker.
//
// Static analysis: for every extension under a root directory, read its
// manifest (package.json) and source, work out what it imports from
// `@raycast/api` / `@raycast/utils`, which command modes it declares, and
// which Node built-ins it touches, then classify it against the API surface
// Invoke v2 actually implements.
//
// Usage:
//   node tools/compat-check/check.mjs <extensions-root> [--trusted] [--out <dir>]
//
//   <extensions-root>  directory containing cloned extensions (recurses to find
//                      every package.json that looks like a Raycast extension)
//   --trusted          assume extensions run unsandboxed (INVOKE_TRUSTED=1), so
//                      Node built-ins and useExec are allowed
//   --out <dir>        where to write report.md / extensions.csv / results.json
//                      (default: ./compat-report next to cwd)

import fs from "node:fs";
import path from "node:path";

// ---------------------------------------------------------------------------
// Invoke v2 supported surface (from packages/api + packages/utils inventory).
// ---------------------------------------------------------------------------

// Named exports from `@raycast/api` that Invoke fully implements.
const API_SUPPORTED = new Set([
  // components
  "List", "Grid", "Detail", "Form", "ActionPanel", "Action", "MenuBarExtra",
  // window / navigation funcs
  "showToast", "showHUD", "closeMainWindow", "open", "popToRoot",
  // prefs / env
  "getPreferenceValues", "environment",
  // storage / clipboard
  "Clipboard", "LocalStorage",
  // enums / namespaces
  "Toast", "LaunchType", "PopToRootType", "Icon", "Color", "Keyboard",
  "Image", "Alert",
  // legacy v1 aliases (M1) — re-exported to the modern namespaced APIs
  "OpenInBrowserAction", "CopyToClipboardAction", "PasteAction", "OpenAction",
  "PushAction", "SubmitFormAction", "ToastStyle", "ImageMask",
  "getLocalStorageItem", "setLocalStorageItem", "removeLocalStorageItem",
  "allLocalStorageItems", "clearLocalStorage", "copyTextToClipboard", "pasteText",
  "preferences", "randomId", "clearSearchBar",
  // M1 host-wired (RPC): real dialog / persisted cache / settings / diagnostic
  "Cache", "confirmAlert", "captureException", "openExtensionPreferences", "openCommandPreferences",
  "useNavigation", // M3 render-on-push navigation
  // selection / application / finder / filesystem (remediation 04)
  "getSelectedText", "getApplications", "getFrontmostApplication", "getDefaultApplication",
  "trash", "showInFinder", "getSelectedFinderItems",
  "AI", // AI.ask (remediation 05)
  "OAuth", "OAuthClient", // OAuth PKCE (M4)
  "Tool", // AI-extension tools (M4) — Tool.Confirmation
  "updateCommandMetadata", // command subtitle updates (now implemented)
  "launchCommand", // inter-command launch (same/named extension; arguments + launchContext) — implemented
  "MenuBarExtra", // menu-bar command mode (M4)
  "render", "fetch", "WindowManagement", "OpenWithAction", // long-tail (~100%)
]);

// `@raycast/api` exports that exist but are stubbed/no-op (run, but degraded).
const API_DEGRADED = new Map([
  // M1 load-stubs — import succeeds; throw (or no-op) only if actually called
  ["BrowserExtension", "loads; throws if called (browser bridge not wired)"],
]);

// `@raycast/api` exports that are stubbed to THROW — hard blockers.
const API_BLOCKING = new Map([
]);

// Common `@raycast/api` exports that are simply ABSENT (import will fail).
// Anything imported from @raycast/api that is not in SUPPORTED/DEGRADED/BLOCKING
// is treated as ABSENT (unknown) anyway; this map just gives nicer messages.
const API_ABSENT = new Map([]);

// `@raycast/utils` exports Invoke implements.
const UTILS_SUPPORTED = new Set([
  "usePromise", "useFetch", "useCachedState", "useSQL", "useCachedPromise",
  "useForm", "showFailureToast", "runAppleScript", "executeSQL", "FormValidation",
  // M1 pure-JS parity helpers
  "getFavicon", "getAvatarIcon", "getProgressIcon", "MutatePromise",
  "useLocalStorage", "useFrecencySorting", "withCache", "createDeeplink", "useAI",
  "OAuthService", "withAccessToken", "getAccessToken", "WithAccessTokenComponentOrFn", "useStreamJSON",
]);

// `@raycast/utils` exports that run but are degraded / trusted-only.
const UTILS_DEGRADED = new Map([
  ["useExec", "only runs in trusted (unsandboxed) extensions; throws in sandbox"],
  ["runPowerShellScript", "Windows-only; throws on macOS (import loads)"],
]);

// Type-only imports we should not penalise — esbuild erases them at runtime, so importing one never
// breaks the module even without a runtime value. (Static analysis can't see `import type`, so the
// well-known Raycast type exports are enumerated here.)
const TYPE_ONLY_HINTS = new Set([
  "LaunchProps", "PreferenceValues", "Application", "FileSystemItem", "Color",
  "Image", "Keyboard", "Toast", "Navigation", "Environment", "Preferences",
  "ImageLike", "FormValue", "FormValues", "KeyEquivalent", "KeyboardShortcut",
  "Component", "ComponentType", "FC", "Fragment", "Dispatch", "SetStateAction",
  "ItemProps", "FormItemRef", "RequestInit", "Response", "FileIcon",
  "CachedPromiseOptions", "AsyncState", "PaginationOptions",
  "ListItem", "ListSection", "ActionPanelItem", "AlertActionStyle", "DeeplinkType",
  "ArgumentsLaunchProps",
]);

// Node built-ins allowed inside the sandbox (safe-builtins.json + curated host-mediated shims).
// `os` and `fs`/`fs/promises` are NOT on the raw safe list — they resolve to consent-gated host
// shims (os-safe.mjs, fs-safe.mjs over fd 4), so for the sandbox verdict they count as supported.
const SAFE_BUILTINS = new Set([
  "assert", "buffer", "console", "crypto", "events", "path", "punycode",
  "querystring", "stream", "string_decoder", "timers", "url", "util", "zlib",
  "process", "os", "fs",
]);

const SUPPORTED_MODES = new Set(["view", "no-view", "menu-bar"]);

// ---------------------------------------------------------------------------
// CLI args
// ---------------------------------------------------------------------------

const argv = process.argv.slice(2);
let root = null;
let trusted = false;
let outDir = path.resolve(process.cwd(), "compat-report");
for (let i = 0; i < argv.length; i++) {
  const a = argv[i];
  if (a === "--trusted") trusted = true;
  else if (a === "--out") outDir = path.resolve(argv[++i]);
  else if (!root) root = path.resolve(a);
}
if (!root) {
  console.error("usage: node check.mjs <extensions-root> [--trusted] [--out <dir>]");
  process.exit(1);
}
if (!fs.existsSync(root)) {
  console.error(`extensions root not found: ${root}`);
  process.exit(1);
}

// ---------------------------------------------------------------------------
// Discovery: find every extension (a package.json with @raycast deps or a
// `commands` array — the Raycast manifest shape).
// ---------------------------------------------------------------------------

const SKIP_DIRS = new Set(["node_modules", ".git", "dist", "build", "out", ".next", "coverage", "assets", "metadata", "media", ".cache"]);

function findExtensions(dir, found = []) {
  let entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return found;
  }
  const pkgPath = path.join(dir, "package.json");
  let isExt = false;
  if (fs.existsSync(pkgPath)) {
    try {
      const pkg = JSON.parse(fs.readFileSync(pkgPath, "utf8"));
      const deps = { ...(pkg.dependencies || {}), ...(pkg.devDependencies || {}) };
      if (Array.isArray(pkg.commands) || deps["@raycast/api"]) {
        isExt = true;
        found.push({ dir, pkg });
      }
    } catch {
      /* malformed package.json — ignore */
    }
  }
  // Don't recurse into an extension's own subtree (commands live at its root).
  if (isExt) return found;
  for (const e of entries) {
    if (!e.isDirectory() || SKIP_DIRS.has(e.name) || e.name.startsWith(".")) continue;
    findExtensions(path.join(dir, e.name), found);
  }
  return found;
}

// ---------------------------------------------------------------------------
// Source scanning
// ---------------------------------------------------------------------------

function listSourceFiles(dir, files = []) {
  let entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return files;
  }
  for (const e of entries) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) {
      if (SKIP_DIRS.has(e.name) || e.name.startsWith(".")) continue;
      listSourceFiles(p, files);
    } else if (/\.(ts|tsx|js|jsx|mjs|cjs)$/.test(e.name)) {
      files.push(p);
    }
  }
  return files;
}

// Parse named imports (and namespace imports) from a given module specifier.
function namedImportsFrom(source, moduleName) {
  const names = new Set();
  let namespace = false;
  // import { a, b as c, type d } from "mod";
  // import Default, { ... } from "mod";
  // import * as NS from "mod";
  // const { a } = require("mod");
  const escMod = moduleName.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  // Bound the import clause to a SINGLE statement: the per-char negative lookahead stops the clause from
  // swallowing a preceding `import`/`from` (semicolon-less code otherwise lets `[^;]*?` span multiple
  // imports and mis-attribute another module's names to this one).
  const importRe = new RegExp(
    `import\\s+((?:(?!\\bfrom\\b|\\bimport\\b)[^;])*?)\\s+from\\s+["']${escMod}["']`,
    "g"
  );
  const requireRe = new RegExp(
    `(?:const|let|var)\\s+(\\{[^}]*\\}|[A-Za-z0-9_$]+)\\s*=\\s*require\\(\\s*["']${escMod}["']\\s*\\)`,
    "g"
  );
  let m;
  while ((m = importRe.exec(source))) {
    const clause = m[1];
    if (/\*\s+as\s+/.test(clause)) {
      namespace = true;
      continue;
    }
    const brace = clause.match(/\{([^}]*)\}/);
    if (brace) {
      // Strip // line and /* */ block comments inside the braces (multi-line imports often comment
      // individual names) so comment text isn't parsed as an imported identifier.
      const inner = brace[1].replace(/\/\/[^\n]*/g, "").replace(/\/\*[\s\S]*?\*\//g, "");
      for (let part of inner.split(",")) {
        part = part.trim().replace(/^type\s+/, "");
        if (!part || !/^[A-Za-z_$]/.test(part)) continue; // skip blanks / non-identifiers
        const name = part.split(/\s+as\s+/)[0].trim();
        if (name) names.add(name);
      }
    }
  }
  while ((m = requireRe.exec(source))) {
    const clause = m[1];
    if (clause.startsWith("{")) {
      for (let part of clause.slice(1, -1).split(",")) {
        part = part.trim();
        if (!part) continue;
        const name = part.split(":")[0].trim();
        if (name) names.add(name);
      }
    } else {
      namespace = true;
    }
  }
  return { names, namespace };
}

// Detect Node built-in imports/requires.
function nodeBuiltins(source) {
  const found = new Set();
  const re = /(?:require\(\s*["']([^"']+)["']\s*\)|from\s+["']([^"']+)["'])/g;
  let m;
  while ((m = re.exec(source))) {
    let spec = m[1] || m[2];
    if (!spec) continue;
    spec = spec.replace(/^node:/, "");
    // bare specifier, single segment (or known builtin), not a relative/scoped pkg
    const base = spec.split("/")[0];
    if (BUILTIN_MODULES.has(base)) found.add(base);
  }
  return found;
}

const BUILTIN_MODULES = new Set([
  "assert", "async_hooks", "buffer", "child_process", "cluster", "console",
  "constants", "crypto", "dgram", "diagnostics_channel", "dns", "domain",
  "events", "fs", "http", "http2", "https", "inspector", "module", "net",
  "os", "path", "perf_hooks", "process", "punycode", "querystring", "readline",
  "repl", "stream", "string_decoder", "timers", "tls", "trace_events", "tty",
  "url", "util", "v8", "vm", "wasi", "worker_threads", "zlib",
]);

// ---------------------------------------------------------------------------
// Classification
// ---------------------------------------------------------------------------

// JSX subcomponents our @raycast/api shim actually defines. A USED-but-missing one renders as
// <undefined> → React "Element type is invalid" → the whole command view crashes. The import-only
// check can't see this (the parent — List/Form/Action/… — IS exported), so we check member usage too.
// Keep in sync with packages/api/src/index.ts.
const SUPPORTED_JSX = new Set([
  "List", "List.Section", "List.Item", "List.Item.Detail", "List.Dropdown", "List.Dropdown.Item", "List.Dropdown.Section", "List.EmptyView",
  "List.Item.Detail.Metadata", "List.Item.Detail.Metadata.Label", "List.Item.Detail.Metadata.TagList", "List.Item.Detail.Metadata.TagList.Item", "List.Item.Detail.Metadata.Separator", "List.Item.Detail.Metadata.Link",
  "Grid", "Grid.Section", "Grid.Item", "Grid.Dropdown", "Grid.Dropdown.Item", "Grid.Dropdown.Section", "Grid.EmptyView",
  "Detail", "Detail.Metadata", "Detail.Metadata.Label", "Detail.Metadata.TagList", "Detail.Metadata.TagList.Item", "Detail.Metadata.Separator", "Detail.Metadata.Link",
  "Form", "Form.TextField", "Form.TextArea", "Form.Checkbox", "Form.Description", "Form.Separator", "Form.PasswordField", "Form.DatePicker", "Form.Dropdown", "Form.Dropdown.Item", "Form.Dropdown.Section",
  "Form.FilePicker", "Form.LinkAccessory", "Form.TagPicker", "Form.TagPicker.Item", "Form.DropdownItem",
  "Action", "Action.CopyToClipboard", "Action.Paste", "Action.OpenInBrowser", "Action.Open", "Action.Push", "Action.SubmitForm",
  "Action.ShowInFinder", "Action.Trash", "Action.OpenWith", "Action.ToggleQuickLook", "Action.CreateQuicklink", "Action.CreateSnippet", "Action.PickDate",
  "ActionPanel", "ActionPanel.Section", "ActionPanel.Submenu", "ActionPanel.Item",
  "MenuBarExtra", "MenuBarExtra.Item", "MenuBarExtra.Section", "MenuBarExtra.Submenu", "MenuBarExtra.Separator",
]);
const JSX_NAMESPACES = ["List", "Grid", "Detail", "Form", "Action", "ActionPanel", "MenuBarExtra"];
// Methods our shim defines on namespace OBJECTS — a call to a missing one is a runtime TypeError.
const SUPPORTED_METHODS = {
  Clipboard: new Set(["copy", "paste", "readText", "read", "clear"]),
  LocalStorage: new Set(["getItem", "setItem", "removeItem", "clear", "allItems"]),
};

function classifyExtension({ dir, pkg }) {
  const files = listSourceFiles(dir);
  const apiNames = new Set();
  let apiNamespace = false;
  const utilsNames = new Set();
  let utilsNamespace = false;
  const builtinsUsed = new Set();
  const jsxUsages = new Set();    // <Ns.Member …> dotted paths
  const methodUsages = new Set(); // Ns.method( calls for namespace objects

  for (const f of files) {
    let src;
    try {
      src = fs.readFileSync(f, "utf8");
    } catch {
      continue;
    }
    const api = namedImportsFrom(src, "@raycast/api");
    api.names.forEach((n) => apiNames.add(n));
    apiNamespace = apiNamespace || api.namespace;
    const utils = namedImportsFrom(src, "@raycast/utils");
    utils.names.forEach((n) => utilsNames.add(n));
    utilsNamespace = utilsNamespace || utils.namespace;
    nodeBuiltins(src).forEach((b) => builtinsUsed.add(b));
    // Member usage for the runtime-member check below.
    for (const m of src.matchAll(/<([A-Z][A-Za-z0-9]*(?:\.[A-Z][A-Za-z0-9]*)+)[\s/>]/g)) jsxUsages.add(m[1]);
    for (const ns of Object.keys(SUPPORTED_METHODS)) {
      for (const m of src.matchAll(new RegExp(`\\b${ns}\\.([a-z][A-Za-z0-9]*)\\s*\\(`, "g"))) methodUsages.add(`${ns}.${m[1]}`);
    }
  }

  const blockers = [];
  const degraded = [];
  const unknown = [];

  // @raycast/api usage
  for (const n of apiNames) {
    if (API_SUPPORTED.has(n)) continue;
    if (TYPE_ONLY_HINTS.has(n)) continue; // type-only imports have no runtime footprint
    if (API_BLOCKING.has(n)) blockers.push(`${n}: ${API_BLOCKING.get(n)}`);
    else if (API_DEGRADED.has(n)) degraded.push(`${n}: ${API_DEGRADED.get(n)}`);
    else if (API_ABSENT.has(n)) blockers.push(`${n}: ${API_ABSENT.get(n)}`);
    else unknown.push(`@raycast/api:${n} (not in Invoke surface — needs review)`);
  }

  // @raycast/utils usage
  for (const n of utilsNames) {
    if (UTILS_SUPPORTED.has(n)) continue;
    if (TYPE_ONLY_HINTS.has(n)) continue; // type-only (erased at runtime)
    if (UTILS_DEGRADED.has(n)) degraded.push(`${n}: ${UTILS_DEGRADED.get(n)}`);
    else unknown.push(`@raycast/utils:${n} (not implemented in Invoke)`);
  }

  // Runtime MEMBER usage (the Toast-class of bug): the parent is exported so the import passes, but a
  // missing subcomponent/method crashes at runtime. Only count members of namespaces actually imported.
  for (const usage of jsxUsages) {
    const segs = usage.split(".");
    const ns = segs[0];
    if (!JSX_NAMESPACES.includes(ns) || !apiNames.has(ns) || SUPPORTED_JSX.has(usage)) continue;
    // `<X.Props>` / `<X.Accessory>` etc. are TYPE generics (e.g. useState<List.Item.Props>), not JSX
    // element types — erased at runtime. Skip the type-only leaves.
    if (["Props", "Values", "Accessory", "ItemProps", "ItemReference"].includes(segs[segs.length - 1])) continue;
    degraded.push(`${usage}: missing @raycast/api member (renders undefined → view crash)`);
  }
  for (const usage of methodUsages) {
    const [ns, method] = usage.split(".");
    if (!apiNames.has(ns) || SUPPORTED_METHODS[ns].has(method)) continue;
    degraded.push(`${usage}: missing @raycast/api method (TypeError)`);
  }

  // Command modes
  const commands = Array.isArray(pkg.commands) ? pkg.commands : [];
  const badModes = [];
  for (const c of commands) {
    const mode = c.mode || "view";
    if (!SUPPORTED_MODES.has(mode)) {
      badModes.push(`${c.name || "?"}: mode "${mode}"`);
    }
  }
  if (badModes.length) {
    blockers.push(`unsupported command mode(s): ${badModes.join(", ")}`);
  }

  // AI extension / tools manifest features
  // AI tools[] (manifest) are supported (M4): the model can call them via the agent loop.
  // extension-level `ai` instructions are now honored by the @-mode agent loop (M4).
  // background `interval` commands are scheduled now (M4).
  // command `arguments[]` (search-bar fields) ARE delivered now: the host collects them (inline chips,
  // with an in-palette form fallback) → INVOKE_ARGUMENTS → child.ts builds LaunchProps.arguments for both
  // view and no-view commands. So declaring arguments[] is no longer a gap.

  // Node built-ins (only matters in sandbox)
  const unsafeBuiltins = [...builtinsUsed].filter((b) => !SAFE_BUILTINS.has(b));
  if (unsafeBuiltins.length && !trusted) {
    blockers.push(`denied Node built-ins in sandbox: ${unsafeBuiltins.join(", ")}`);
  } else if (unsafeBuiltins.length && trusted) {
    degraded.push(`uses Node built-ins (ok in trusted mode): ${unsafeBuiltins.join(", ")}`);
  }

  // Namespace import means we can't see which members are used — flag for review.
  if (apiNamespace) unknown.push("namespace import of @raycast/api (member usage unverified)");

  let status;
  if (blockers.length || unknown.length) status = "UNSUPPORTED";
  else if (degraded.length) status = "DEGRADED";
  else status = "SUPPORTED";

  return {
    name: pkg.name || path.basename(dir),
    title: pkg.title || pkg.name || path.basename(dir),
    dir: path.relative(root, dir) || ".",
    status,
    commands: commands.length,
    modes: [...new Set(commands.map((c) => c.mode || "view"))].join("|"),
    apiImports: [...apiNames].sort(),
    utilsImports: [...utilsNames].sort(),
    builtins: [...builtinsUsed].sort(),
    blockers,
    degraded,
    unknown,
  };
}

// ---------------------------------------------------------------------------
// Run
// ---------------------------------------------------------------------------

console.error(`Scanning ${root} ...`);
const exts = findExtensions(root);
console.error(`Found ${exts.length} extension(s). Classifying${trusted ? " (trusted mode)" : ""} ...`);

const results = exts.map(classifyExtension).sort((a, b) => a.name.localeCompare(b.name));

const counts = { SUPPORTED: 0, DEGRADED: 0, UNSUPPORTED: 0 };
for (const r of results) counts[r.status]++;

// Aggregate which gaps block the most extensions.
const gapTally = new Map();
function tallyGap(label) {
  gapTally.set(label, (gapTally.get(label) || 0) + 1);
}
for (const r of results) {
  const seen = new Set();
  for (const b of [...r.blockers, ...r.degraded, ...r.unknown]) {
    const key = b.split(":")[0].split(" (")[0].trim();
    if (!seen.has(key)) {
      seen.add(key);
      tallyGap(key);
    }
  }
}
const topGaps = [...gapTally.entries()].sort((a, b) => b[1] - a[1]);

// ---------------------------------------------------------------------------
// Output
// ---------------------------------------------------------------------------

fs.mkdirSync(outDir, { recursive: true });

// JSON
fs.writeFileSync(
  path.join(outDir, "results.json"),
  JSON.stringify({ root, trusted, counts, topGaps, results }, null, 2)
);

// CSV
const csvRows = [
  ["name", "title", "status", "dir", "commands", "modes", "blockers", "degraded", "unknown_apis", "node_builtins"].join(","),
];
function csvCell(v) {
  const s = String(v ?? "");
  return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
}
for (const r of results) {
  csvRows.push([
    csvCell(r.name),
    csvCell(r.title),
    csvCell(r.status),
    csvCell(r.dir),
    csvCell(r.commands),
    csvCell(r.modes),
    csvCell(r.blockers.join(" | ")),
    csvCell(r.degraded.join(" | ")),
    csvCell([...r.unknown].join(" | ")),
    csvCell(r.builtins.join(" ")),
  ].join(","));
}
fs.writeFileSync(path.join(outDir, "extensions.csv"), csvRows.join("\n"));

// Markdown report
const md = [];
md.push(`# Invoke v2 — Raycast extension compatibility report`);
md.push("");
md.push(`- **Root scanned:** \`${root}\``);
md.push(`- **Mode:** ${trusted ? "trusted (unsandboxed)" : "sandboxed (default)"}`);
md.push(`- **Extensions found:** ${results.length}`);
md.push("");
md.push(`## Summary`);
md.push("");
md.push(`| Status | Count | % |`);
md.push(`|---|---:|---:|`);
for (const s of ["SUPPORTED", "DEGRADED", "UNSUPPORTED"]) {
  const pct = results.length ? ((counts[s] / results.length) * 100).toFixed(1) : "0.0";
  md.push(`| ${s} | ${counts[s]} | ${pct}% |`);
}
md.push("");
md.push(`## Top gaps (extensions blocked/degraded per missing capability)`);
md.push("");
md.push(`| Capability | Extensions affected |`);
md.push(`|---|---:|`);
for (const [g, n] of topGaps.slice(0, 25)) md.push(`| ${g} | ${n} |`);
md.push("");
for (const status of ["UNSUPPORTED", "DEGRADED", "SUPPORTED"]) {
  const group = results.filter((r) => r.status === status);
  md.push(`## ${status} (${group.length})`);
  md.push("");
  if (status === "SUPPORTED") {
    md.push(group.map((r) => `\`${r.name}\``).join(", ") || "_none_");
    md.push("");
    continue;
  }
  for (const r of group) {
    md.push(`### \`${r.name}\` — ${r.title}`);
    md.push(`- dir: \`${r.dir}\` · commands: ${r.commands} · modes: ${r.modes}`);
    if (r.blockers.length) md.push(`- **Blockers:** ${r.blockers.join("; ")}`);
    if (r.degraded.length) md.push(`- Degraded: ${r.degraded.join("; ")}`);
    if (r.unknown.length) md.push(`- Needs review: ${r.unknown.join("; ")}`);
    md.push("");
  }
}
fs.writeFileSync(path.join(outDir, "report.md"), md.join("\n"));

console.error("");
console.error(`Done. ${results.length} extensions:`);
console.error(`  SUPPORTED:   ${counts.SUPPORTED}`);
console.error(`  DEGRADED:    ${counts.DEGRADED}`);
console.error(`  UNSUPPORTED: ${counts.UNSUPPORTED}`);
console.error("");
console.error(`Wrote:`);
console.error(`  ${path.join(outDir, "report.md")}`);
console.error(`  ${path.join(outDir, "extensions.csv")}`);
console.error(`  ${path.join(outDir, "results.json")}`);
