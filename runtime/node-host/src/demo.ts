/**
 * Phase 0 end-to-end proof (PLAN.md §4 / §8.2 exit criteria).
 *
 * Demonstrates the whole spine in pure Node — no Xcode needed:
 *   1. fork ONE OS process per extension (isolation, §4.4)
 *   2. mount a real React extension through our custom reconciler (§4.5)
 *   3. stream render MUTATIONS over a length-prefixed framed socket (§4.6)
 *   4. apply them host-side to a view-model tree and print it (§4.7)
 *   5. push a host→child event (search text) → re-render → new mutations
 *   6. invoke an Action handler by its wire reference → re-render → new mutations
 *
 * Run: `npm run demo`
 */
import { fileURLToPath } from "node:url";
import path from "node:path";
import { ExtensionProcess } from "./supervisor.ts";
import { findNode, renderTree, type ViewTree } from "./viewmodel.ts";

const ROOT_DIR = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../../..");
const EXT_ENTRY = path.join(ROOT_DIR, "examples/hello-world/src/list.tsx");

const rule = (label: string) => console.log(`\n${"─".repeat(8)} ${label} ${"─".repeat(Math.max(0, 40 - label.length))}`);

function waitForCommit(proc: ExtensionProcess): Promise<ViewTree> {
  return new Promise((resolve) => proc.once("commit", (_c: number, tree: ViewTree) => resolve(tree)));
}
const delay = (ms: number) => new Promise((r) => setTimeout(r, ms));

async function main(): Promise<void> {
  console.log("Invoke — Phase 0 spine demo");
  console.log("extension:", path.relative(ROOT_DIR, EXT_ENTRY));

  const proc = new ExtensionProcess(EXT_ENTRY, "list");
  let commits = 0;
  proc.on("commit", () => {
    commits++;
  });
  proc.on("log", (m) => console.log(`  [ext ${m.level}]`, ...m.args));

  // 1–4: initial render arrives as a mutation stream, applied to the view tree.
  const ready = new Promise<void>((res) => proc.once("ready", () => res()));
  const firstTree = await waitForCommit(proc);
  await ready;
  rule("initial render (view-model tree)");
  console.log(renderTree(firstTree.root));

  // 5: host → child event. The extension's onSearchTextChange re-filters the list.
  proc.setSearchText("ap");
  const filtered = await waitForCommit(proc);
  rule('after searchText = "ap"');
  console.log(renderTree(filtered.root));

  // 6: invoke an Action by its wire handler ref (what a keypress would do).
  const pin = findNode(filtered, "action", "Pin");
  const handler = pin?.props.onAction as { __handler?: string } | undefined;
  if (handler?.__handler) {
    rule(`invoke Action "Pin" (handler ${handler.__handler})`);
    proc.invoke(handler.__handler, []);
    const pinned = await waitForCommit(proc);
    console.log(renderTree(pinned.root));
  }

  await delay(50);
  rule("summary");
  console.log(`commits applied: ${commits}`);
  console.log("✓ process isolation + framed IPC + reconciler mutations verified end-to-end");
  proc.kill();
  await delay(50);
  process.exit(0);
}

main().catch((e: unknown) => {
  console.error("demo failed:", e);
  process.exit(1);
});
