// Build the Invoke Store index from a local clone of github.com/raycast/extensions.
//
// Emits tools/store-index/extensions-index.json — the metadata the in-app Store browses (name, title,
// description, author, categories, icon, commands). The app derives, per entry:
//   • icon URL   : https://raw.githubusercontent.com/raycast/extensions/main/extensions/<name>/assets/<icon>
//   • install src: a sparse-checkout of `extensions/<name>` from the same repo (see install-extension.mjs)
//
// Usage:
//   node tools/store-index/build.mjs [<extensions-dir>]
// <extensions-dir> defaults to the `extensions/` subdir of a raycast/extensions clone; it holds one
// folder per extension (each with a package.json + assets/).
import fs from "node:fs";
import path from "node:path";

const REPO = "raycast/extensions";
const REF = "main";
const SRC = process.argv[2] || "/Users/test/Documents/code/extensions/extensions";
const OUT = path.resolve(path.dirname(new URL(import.meta.url).pathname), "extensions-index.json");

const dirs = fs
  .readdirSync(SRC, { withFileTypes: true })
  .filter((e) => e.isDirectory() && !e.name.startsWith("."))
  .map((e) => e.name)
  .sort((a, b) => a.localeCompare(b));

const extensions = [];
let skipped = 0;
for (const name of dirs) {
  const pkgPath = path.join(SRC, name, "package.json");
  let pkg;
  try {
    pkg = JSON.parse(fs.readFileSync(pkgPath, "utf8"));
  } catch {
    skipped++;
    continue;
  }
  if (!pkg.title || !Array.isArray(pkg.commands)) {
    skipped++;
    continue;
  }
  // Only keep an icon we can actually fetch (the file must exist in assets/).
  let icon = typeof pkg.icon === "string" ? pkg.icon : "";
  if (icon && !fs.existsSync(path.join(SRC, name, "assets", icon))) icon = "";
  extensions.push({
    name, // folder name == repo path segment (extensions/<name>)
    title: String(pkg.title),
    description: typeof pkg.description === "string" ? pkg.description : "",
    author: typeof pkg.author === "string" ? pkg.author : "",
    categories: Array.isArray(pkg.categories) ? pkg.categories.filter((c) => typeof c === "string") : [],
    icon,
    commands: pkg.commands
      .filter((c) => c && typeof c.name === "string")
      .map((c) => ({ name: c.name, title: typeof c.title === "string" ? c.title : c.name, mode: c.mode || "view" })),
  });
}

const index = { repo: REPO, ref: REF, generatedAt: new Date().toISOString(), count: extensions.length, extensions };
fs.writeFileSync(OUT, JSON.stringify(index));
console.log(`Wrote ${extensions.length} extensions (${skipped} skipped) → ${OUT}`);
console.log(`  size: ${(fs.statSync(OUT).size / 1024 / 1024).toFixed(2)} MB`);
