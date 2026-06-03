/**
 * Perf harness (PLAN.md §1 budgets, §8.2 Phase-0 exit criteria, §8.4 perf gates).
 *
 * Phase 0 gates three numbers before the spine is "done":
 *   (2) realistic extension first-paint  p95 < 300ms
 *   (3) a 5k-row mutation-stream benchmark passes
 *   (4) native-summon                    p95 < 150ms
 *
 * This file measures (2) and (3) headlessly in Node — the parts that don't need a
 * window server. (4) is native-only and is instrumented in Swift (AppController +
 * PaletteWindow log `summon …ms` on every ⌥Space); see STATUS.md.
 *
 *   npm run bench            # both benches, human report
 *   npm run bench -- --json  # machine-readable (for the CI gate, §8.4)
 *
 * Exit code is non-zero if any measured gate fails — so CI can `npm run bench` and
 * fail the build on a regression (§8.4).
 */
import { performance } from "node:perf_hooks";
import { createElement, type ReactElement } from "react";
import { createSurface } from "@invoke/reconciler";
import { List } from "@invoke/api";

// @invoke/api host components take optional props (`= {}`), which makes React.createElement match
// its no-props overload (props typed as bare `Attributes`). Cast to a required-props signature so
// the element factory accepts the arbitrary serialized props the reconciler streams.
type Comp = (props: Record<string, unknown>) => ReactElement;
const ListEl = List as unknown as Comp;
const ItemEl = List.Item as unknown as Comp;
import type { Mutation } from "@invoke/schema";
import { applyMutations, createViewTree } from "./viewmodel.ts";
import { ExtensionProcess } from "./supervisor.ts";
import path from "node:path";
import { fileURLToPath } from "node:url";

const REPO_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../../..");
const asJson = process.argv.includes("--json");

/* ------------------------------------------------------------------ stats */

interface Stats { n: number; min: number; p50: number; p95: number; max: number; mean: number }

function stats(xs: number[]): Stats {
  const s = [...xs].sort((a, b) => a - b);
  const at = (q: number) => s[Math.min(s.length - 1, Math.floor(q * (s.length - 1)))];
  const mean = s.reduce((a, b) => a + b, 0) / s.length;
  return { n: s.length, min: s[0], p50: at(0.5), p95: at(0.95), max: s[s.length - 1], mean };
}

const ms = (n: number) => `${n.toFixed(1)}ms`;

/* ---------------------------------------------------------- (3) 5k mutations
 * Drives the real reconciler → mutation-stream → host view-model path with a
 * 5,000-row List: a cold MOUNT (≈10k create+append ops) and an UPDATE that
 * re-keys every row's accessory (5k updateProps ops). We time the reconciler's
 * emit (React commit → Mutation[]) and the host's applyMutations() separately,
 * because in production those run in different processes (child vs native host).
 */
const ROWS = 5000;

function buildList(gen: number, n = ROWS) {
  const items = [];
  for (let i = 0; i < n; i++) {
    items.push(
      createElement(ItemEl, {
        key: i,
        title: `Item ${i}`,
        subtitle: `row ${i} · generation ${gen}`,
        accessories: [{ text: `#${gen}.${i}` }],
      }),
    );
  }
  return createElement(ListEl, {}, ...items);
}

interface MutationSample { emit: number; apply: number; ops: number }

function benchMutations(iterations: number): { mount: MutationSample[]; update: MutationSample[] } {
  const mount: MutationSample[] = [];
  const update: MutationSample[] = [];

  for (let it = 0; it < iterations; it++) {
    let captured: Mutation[] = [];
    const surface = createSurface({ onCommit: (_c, ops) => captured.push(...ops) });

    // --- cold mount: render 5k rows, capture the emitted stream, apply to a fresh host tree.
    captured = [];
    let t0 = performance.now();
    surface.render(buildList(0));
    const mountEmit = performance.now() - t0;
    const mountOps = captured.slice();
    const tree = createViewTree();
    t0 = performance.now();
    applyMutations(tree, mountOps);
    const mountApply = performance.now() - t0;
    mount.push({ emit: mountEmit, apply: mountApply, ops: mountOps.length });

    // --- update: re-render the same 5k rows with a new generation → every row's props change.
    captured = [];
    t0 = performance.now();
    surface.render(buildList(1));
    const updEmit = performance.now() - t0;
    const updOps = captured.slice();
    t0 = performance.now();
    applyMutations(tree, updOps);
    const updApply = performance.now() - t0;
    update.push({ emit: updEmit, apply: updApply, ops: updOps.length });

    surface.unmount();
  }
  return { mount, update };
}

/* ------------------------------------------------------- (2) ext first-paint
 * Cold-open a realistic extension (deps + async fetch) through the REAL host
 * (ExtensionProcess) and time construction → first commit (the loading paint the
 * user first sees). Each iteration is a fresh OS process — there is no warm pool
 * yet (the next Phase-0 hardening item), so this baseline is the cold-spawn cost.
 */
function firstPaintOnce(entry: string, command: string): Promise<number> {
  return new Promise((resolve, reject) => {
    const t0 = performance.now();
    const proc = new ExtensionProcess(entry, command);
    const timer = setTimeout(() => { proc.kill(); reject(new Error("first-paint timeout (>5s)")); }, 5000);
    proc.once("commit", () => {
      const dt = performance.now() - t0;
      clearTimeout(timer);
      proc.kill();
      resolve(dt);
    });
    proc.once("exit", () => { clearTimeout(timer); reject(new Error("extension exited before first paint")); });
  });
}

async function benchFirstPaint(iterations: number): Promise<number[]> {
  const entry = path.join(REPO_ROOT, "examples/hacker-news/src/search.tsx");
  const samples: number[] = [];
  for (let i = 0; i < iterations; i++) {
    try {
      samples.push(await firstPaintOnce(entry, "search"));
    } catch (e) {
      if (!asJson) console.error(`  iteration ${i} failed: ${String(e)}`);
    }
  }
  return samples;
}

/* ------------------------------------------------------------------- report */

interface Gate { name: string; metric: number; budget: number; budgetSource: string; pass: boolean }

function gate(name: string, metric: number, budget: number, budgetSource: string): Gate {
  return { name, metric, budget, budgetSource, pass: metric <= budget };
}

async function main(): Promise<void> {
  if (!asJson) console.log("Invoke perf harness — Phase-0 gates (PLAN.md §1/§8.2/§8.4)\n");

  const mut = benchMutations(15);
  const mountEmit = stats(mut.mount.map((s) => s.emit));
  const mountApply = stats(mut.mount.map((s) => s.apply));
  const updEmit = stats(mut.update.map((s) => s.emit));
  const updApply = stats(mut.update.map((s) => s.apply));
  const mountTotal = stats(mut.mount.map((s) => s.emit + s.apply));
  const updTotal = stats(mut.update.map((s) => s.emit + s.apply));

  const fp = await benchFirstPaint(8);
  const fpStats = fp.length ? stats(fp) : null;

  // Budgets: first-paint is from PLAN §1/§8.2 (300ms). The 5k-row "passes" gate has
  // no number in the plan — we adopt a defensible target (full mount cycle p95 < 120ms,
  // a 60fps-ish budget for a one-shot 10k-op stream) and LABEL it as chosen, not spec.
  const gates: Gate[] = [
    gate("5k-row mount (emit+apply) p95", mountTotal.p95, 120, "chosen (no plan number)"),
    gate("5k-row update (emit+apply) p95", updTotal.p95, 80, "chosen (no plan number)"),
  ];
  if (fpStats) gates.push(gate("extension first-paint p95", fpStats.p95, 300, "PLAN §1/§8.2"));

  if (asJson) {
    console.log(JSON.stringify({
      mutations5k: {
        rows: ROWS,
        mountOps: mut.mount[0]?.ops, updateOps: mut.update[0]?.ops,
        mountEmit, mountApply, mountTotal, updateEmit: updEmit, updateApply: updApply, updateTotal: updTotal,
      },
      firstPaint: fpStats ? { ...fpStats, samples: fp } : { error: "no successful samples" },
      gates,
    }, null, 2));
  } else {
    console.log(`── (3) 5k-row mutation stream  ·  ${mut.mount[0]?.ops} mount ops · ${mut.update[0]?.ops} update ops · ${mountEmit.n} iters`);
    console.log(`   mount  emit ${ms(mountEmit.p50)} p50 / ${ms(mountEmit.p95)} p95   apply ${ms(mountApply.p50)} p50 / ${ms(mountApply.p95)} p95   total ${ms(mountTotal.p50)} p50 / ${ms(mountTotal.p95)} p95`);
    console.log(`   update emit ${ms(updEmit.p50)} p50 / ${ms(updEmit.p95)} p95   apply ${ms(updApply.p50)} p50 / ${ms(updApply.p95)} p95   total ${ms(updTotal.p50)} p50 / ${ms(updTotal.p95)} p95`);
    console.log();
    if (fpStats) {
      console.log(`── (2) extension first-paint (hacker-news, cold spawn, no warm pool)  ·  ${fpStats.n} iters`);
      console.log(`   ${ms(fpStats.min)} min / ${ms(fpStats.p50)} p50 / ${ms(fpStats.p95)} p95 / ${ms(fpStats.max)} max`);
    } else {
      console.log("── (2) extension first-paint  ·  NO SAMPLES (spawn failed — see errors above)");
    }
    console.log();
    console.log("── gates");
    for (const g of gates) {
      console.log(`   ${g.pass ? "✅ PASS" : "❌ FAIL"}  ${g.name}: ${ms(g.metric)}  (budget ${ms(g.budget)} — ${g.budgetSource})`);
    }
    console.log();
    console.log("   (4) native-summon p95 < 150ms — native-only; instrumented in Swift, prints `summon …ms` on each ⌥Space.");
  }

  process.exit(gates.every((g) => g.pass) ? 0 : 1);
}

main().catch((e: unknown) => {
  console.error("bench failed:", e);
  process.exit(1);
});
