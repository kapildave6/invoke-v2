/**
 * RED-TEAM EXTENSION (PLAN.md §8.2 Phase-0 exit #1, §8.4 security gate).
 *
 * A deliberately hostile `view` command. It runs inside a normal child process under
 * `lockdown()` and tries every capability-escape we claim to deny: reading the filesystem,
 * spawning processes, opening sockets, leaking host info, minting a CJS `require`, and the
 * native-binding hatch. Each attempt is wrapped so it CANNOT crash the module; the verdict
 * (BLOCKED vs ESCAPED) is rendered into the view-model tree, where redteam.ts asserts on it.
 *
 * Two control probes (`node:path`, `node:crypto`) MUST succeed — they prove the allowlist
 * isn't simply blocking everything (which would pass the gate for the wrong reason).
 *
 * If this extension ever renders an ESCAPED row, isolation is broken and CI must fail.
 */
import { List } from "@invoke/api";

type Expect = "deny" | "allow" | "open";

interface Probe {
  name: string;
  expect: Expect;
  blocked: boolean;
  detail: string;
}

const probes: Probe[] = [];

async function run(name: string, expect: Expect, fn: () => Promise<unknown> | unknown): Promise<void> {
  try {
    await fn();
    probes.push({ name, expect, blocked: false, detail: "call returned without error" });
  } catch (e) {
    probes.push({ name, expect, blocked: true, detail: String(e instanceof Error ? e.message : e).slice(0, 90) });
  }
}

// ── Escapes that MUST be denied ──────────────────────────────────────────────
await run("fs read /etc/passwd", "deny", async () => {
  const fs = await import("node:fs/promises");
  return fs.readFile("/etc/passwd", "utf8");
});
await run("child_process exec", "deny", async () => {
  const cp = await import("node:child_process");
  return cp.execSync("id").toString();
});
await run("net outbound connect", "deny", async () => {
  const net = await import("node:net");
  return net.connect(80, "example.com");
});
await run("os host-info disclosure", "deny", async () => {
  const os = await import("node:os");
  return os.userInfo();
});
await run("module createRequire(fs)", "deny", async () => {
  const mod = await import("node:module");
  return mod.createRequire(import.meta.url)("fs");
});
await run("process.binding native hatch", "deny", () => {
  const p = process as unknown as { binding: (n: string) => unknown };
  return p.binding("fs");
});

// ── Controls that MUST keep working (pure-compute builtins) ───────────────────
await run("path.join (control)", "allow", async () => {
  const path = await import("node:path");
  return path.join("a", "b");
});
await run("crypto.randomUUID (control)", "allow", async () => {
  const crypto = await import("node:crypto");
  return crypto.randomUUID();
});

// ── Network egress: OPEN BY DESIGN in v1 ─────────────────────────────────────
// `fetch`/`WebSocket` are Web-standard globals, NOT Node builtins, so lockdown() does not gate
// them — and shouldn't: they are the @invoke/utils `useFetch` surface extensions depend on.
// PLAN §5.7 puts fine-grained NETWORK permission in the v2 declared-permission manifest; v1
// relies on curation + isolation. These probes make that gap EXPLICIT so the gate is never read
// as "network is contained". They assert reachability only — no real connection (CI stays hermetic).
await run("fetch egress (open by design; v2-gated §5.7)", "open", () => {
  if (typeof fetch !== "function") throw new Error("fetch not present");
  return "reachable";
});
await run("WebSocket egress (open by design; v2-gated §5.7)", "open", () => {
  if (typeof WebSocket !== "function") throw new Error("WebSocket not present");
  return "reachable";
});

export default function Command() {
  return (
    <List navigationTitle="Red-team isolation probes" searchBarPlaceholder="capability escapes">
      <List.Section title="Capability probes">
        {probes.map((p) => (
          <List.Item
            key={p.name}
            title={p.name}
            subtitle={p.blocked ? "BLOCKED" : "ESCAPED"}
            expect={p.expect}
            probeDetail={p.detail}
            accessories={[{ tag: p.blocked ? "blocked" : "escaped" }]}
          />
        ))}
      </List.Section>
    </List>
  );
}
