/**
 * Red-team security gate (PLAN.md §8.2 Phase-0 exit #1, §8.4 "the red-team extension runs in CI
 * permanently; any capability escape fails the build").
 *
 * Boots the hostile fixture as a real extension (own process, lockdown applied), reads the
 * verdict it rendered into the view-model tree, and exits non-zero if ANY denied capability
 * escaped (or any control probe was wrongly blocked). Also asserts the host-side RPC allowlist
 * rejects un-granted methods — the second half of the §4.4 capability model.
 *
 * Run: `npm run redteam`
 */
import { fileURLToPath } from "node:url";
import path from "node:path";
import { ExtensionProcess, isAllowedRpcMethod } from "./supervisor.ts";
import { type ViewTree } from "./viewmodel.ts";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const FIXTURE = path.join(HERE, "fixtures/red-team.tsx");

const delay = (ms: number): Promise<void> => new Promise((r) => setTimeout(r, ms));

type Expect = "deny" | "allow" | "open" | "mediated";

interface ProbeRow {
  name: string;
  expect: Expect;
  blocked: boolean;
  detail: string;
}

function readProbes(tree: ViewTree): ProbeRow[] {
  const rows: ProbeRow[] = [];
  for (const node of tree.index.values()) {
    if (node.type !== "list-item") continue;
    const p = node.props;
    const expect: Expect =
      p.expect === "allow" ? "allow" : p.expect === "open" ? "open" : p.expect === "mediated" ? "mediated" : "deny";
    rows.push({
      name: String(p.title ?? "?"),
      expect,
      blocked: p.subtitle === "BLOCKED",
      detail: String(p.probeDetail ?? ""),
    });
  }
  return rows;
}

async function main(): Promise<void> {
  console.log("Invoke — red-team isolation gate");
  console.log("fixture:", path.relative(path.join(HERE, "../../.."), FIXTURE));

  const proc = new ExtensionProcess(FIXTURE, "red-team");
  proc.on("log", (m) => console.log(`  [ext ${m.level}]`, ...m.args));

  const tree = await new Promise<ViewTree>((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error("extension never rendered (timeout)")), 10_000);
    proc.once("commit", (_c: number, t: ViewTree) => {
      clearTimeout(timer);
      resolve(t);
    });
    proc.once("exit", (code) => reject(new Error(`extension exited early (code ${code})`)));
  });

  const probes = readProbes(tree);
  proc.kill();

  // ── Part 1: built-in capability denial (proven end-to-end through the running extension) ──
  console.log("\nCapability probes (run inside the locked-down extension process):");
  const failures: string[] = [];
  let openCount = 0;
  let mediatedCount = 0;
  for (const p of probes) {
    if (p.expect === "open") {
      // Informational: a documented, intended-open capability — never fails the gate.
      openCount++;
      console.log(`  ⚠ [open ] ${p.name.padEnd(42)} ${p.blocked ? "unreachable" : "OPEN"}`);
      continue;
    }
    if (p.expect === "mediated") {
      // Host-mediated capability (fs over fd 4): not denied at the sandbox layer; the host gates it
      // with per-(extension, directory) consent in production. Informational — never fails the gate.
      mediatedCount++;
      console.log(`  ⚠ [media] ${p.name.padEnd(42)} ${p.blocked ? "unreachable" : "MEDIATED"}`);
      continue;
    }
    const ok = p.expect === "deny" ? p.blocked : !p.blocked;
    const verdict = p.blocked ? "BLOCKED" : p.expect === "allow" ? "ALLOWED" : "ESCAPED";
    const want = p.expect === "deny" ? "deny" : "allow";
    console.log(`  ${ok ? "✓" : "✗"} [${want.padEnd(5)}] ${p.name.padEnd(42)} ${verdict}  — ${p.detail}`);
    if (!ok) {
      failures.push(
        p.expect === "deny"
          ? `ESCAPE: "${p.name}" reached a denied capability`
          : `OVER-BLOCK: control "${p.name}" should have been allowed`,
      );
    }
  }
  if (probes.length === 0) failures.push("no probes rendered — fixture did not run");
  if (openCount > 0) {
    console.log("\n  ⚠ Network egress (fetch/WebSocket) is intentionally OPEN to extensions in v1 (the");
    console.log("    useFetch SDK surface). Fine-grained network permission is gated in v2 (PLAN §5.7) —");
    console.log("    a documented, accepted gap. This gate proves Node-built-in denial, NOT net containment.");
  }
  if (mediatedCount > 0) {
    console.log("\n  ⚠ Filesystem (fs/fs-promises) is HOST-MEDIATED, not sandbox-denied: `import \"fs\"`");
    console.log("    resolves to the virtual shim that forwards to the host over fd 4. The host canonicalizes");
    console.log("    the path and gates it with per-(extension, directory) consent (remediation 01). Raw");
    console.log("    node:fs stays unreachable — the module/process.binding denials above prove that route.");
  }

  // ── Part 2: host RPC allowlist (the other half of §4.4) ──
  console.log("\nRPC capability allowlist (host-enforced in the supervisor):");
  const mustReject = ["fs.readFile", "child_process.exec", "net.connect", "eval", "anything.else"];
  const mustAllow = ["clipboard.copy", "toast.show", "window.close"];
  for (const m of mustReject) {
    const allowed = isAllowedRpcMethod(m);
    console.log(`  ${allowed ? "✗" : "✓"} reject  ${m.padEnd(24)} ${allowed ? "ALLOWED" : "rejected"}`);
    if (allowed) failures.push(`RPC allowlist leaked: "${m}" should be rejected`);
  }
  for (const m of mustAllow) {
    const allowed = isAllowedRpcMethod(m);
    console.log(`  ${allowed ? "✓" : "✗"} allow   ${m.padEnd(24)} ${allowed ? "allowed" : "REJECTED"}`);
    if (!allowed) failures.push(`RPC allowlist regressed: "${m}" should be allowed`);
  }

  await delay(30);
  console.log("");
  if (failures.length > 0) {
    console.error("✗ RED-TEAM GATE FAILED:");
    for (const f of failures) console.error(`  - ${f}`);
    process.exit(1);
  }
  const enforced = probes.length - openCount - mediatedCount;
  console.log(
    `✓ red-team gate passed: ${enforced} enforced capability probes + ${mustReject.length + mustAllow.length} allowlist checks` +
      `${openCount ? `; ${openCount} egress probes documented OPEN (v2-gated §5.7)` : ""}` +
      `${mediatedCount ? `; ${mediatedCount} fs probe host-mediated (consent-gated)` : ""} (PLAN.md §8.2 exit #1)`,
  );
  process.exit(0);
}

main().catch((e: unknown) => {
  console.error("red-team gate errored:", e);
  process.exit(1);
});
