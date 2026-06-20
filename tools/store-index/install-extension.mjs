// Fetch one extension's source from github.com/raycast/extensions and run it through the existing
// importer (compat check + dep install + copy into imported/). Used by the in-app Store's Install action.
//
//   node tools/store-index/install-extension.mjs <name> [--trusted]
//
// Only the importer's JSON report reaches STDOUT (so Swift parses it like a local import); our own
// progress goes to STDERR. Exits with the importer's status.
import { mkdtempSync, rmSync, existsSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";

const REPO = "https://github.com/raycast/extensions.git";
const REF = "main";
const ROOT = path.resolve(path.dirname(new URL(import.meta.url).pathname), "../..");

const name = process.argv[2];
const trusted = process.argv.includes("--trusted");
if (!name || name.startsWith("--")) {
  console.error("usage: install-extension.mjs <name> [--trusted]");
  process.exit(2);
}
// Extension folder names are simple slugs — refuse anything that could escape `extensions/<name>`.
if (!/^[A-Za-z0-9._-]+$/.test(name)) {
  console.error(`[invoke:store] invalid extension name: ${name}`);
  process.exit(2);
}

const log = (m) => console.error(`[invoke:store] ${m}`);
const tmp = mkdtempSync(path.join(tmpdir(), "invoke-store-"));
function git(args, cwd) {
  return spawnSync("git", args, { cwd, stdio: ["ignore", "ignore", "inherit"] }).status === 0;
}
try {
  log(`fetching extensions/${name}…`);
  // Partial + sparse clone: download the commit tree but only this extension's blobs.
  if (!git(["clone", "--filter=blob:none", "--no-checkout", "--depth", "1", "--branch", REF, REPO, tmp])) {
    log("git clone failed (network? git installed?)");
    process.exit(1);
  }
  git(["sparse-checkout", "init", "--cone"], tmp);
  git(["sparse-checkout", "set", `extensions/${name}`], tmp);
  if (!git(["checkout", REF], tmp)) {
    log("git checkout failed");
    process.exit(1);
  }
  const src = path.join(tmp, "extensions", name);
  if (!existsSync(path.join(src, "package.json"))) {
    log(`extensions/${name} not found in ${REPO}`);
    process.exit(1);
  }
  log("fetched; running importer…");
  const importTs = path.join(ROOT, "runtime/node-host/src/import.ts");
  const r = spawnSync(
    "node",
    ["--import", "tsx", importTs, src, "--json", ...(trusted ? ["--trusted"] : [])],
    { cwd: ROOT, stdio: ["ignore", "inherit", "inherit"] }, // import.ts JSON report → our stdout
  );
  process.exit(r.status ?? 1);
} finally {
  rmSync(tmp, { recursive: true, force: true });
}
