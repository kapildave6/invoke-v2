/**
 * Per-extension child process (PLAN.md §4.4).
 *
 * One of these runs PER extension, in its OWN OS process — the real isolation
 * boundary. It loads the extension bundle, mounts it through @invoke/reconciler,
 * and streams render mutations to the host over a single framed socket (fd 3).
 * The host calls back (action handlers, search text) over the same socket.
 *
 * In production this process is locked down further: Node built-ins (fs/net/
 * child_process) denied by default, capability only via the allowlisted RPC
 * (PLAN.md §4.4). Here we keep it readable; the isolation *shape* is what matters.
 *
 * Spawned as:  node --import tsx child.ts <extensionEntry> <commandName>
 */
import net from "node:net";
import { pathToFileURL } from "node:url";
import { createElement, type ReactNode } from "react";
import { createSurface } from "@invoke/reconciler";
import { __setHostBridge, __setNavController, __invokeCallback, showToast, Toast } from "@invoke/api";
import {
  type ChildBound,
  type HostBound,
  encodeFrame,
  FrameDecoder,
} from "@invoke/schema";
import { lockdown } from "./sandbox.ts";
import { installFsSyncBridge } from "./fs-bridge.ts";

const [entry, command] = process.argv.slice(2);

// fd 3 is a duplex socketpair created by the parent's spawn() stdio config.
const sock = new net.Socket({ fd: 3, readable: true, writable: true });
const send = (msg: HostBound): void => void sock.write(encodeFrame(msg));

/** If `e` is a sandbox denial, return the denied module name (e.g. "fs", "process.binding"). */
function sandboxDeniedModule(e: unknown): string | undefined {
  const m = String((e as { message?: string })?.message ?? e);
  if (!m.includes("[invoke:sandbox]")) return undefined;
  const quoted = m.match(/"([^"]+)"/); // import of Node built-in "fs"  |  require("fs")
  if (quoted) return quoted[1].replace(/^node:/, "");
  const proc = m.match(/process\.([A-Za-z0-9_]+)/);
  return proc ? `process.${proc[1]}` : "a Node built-in";
}

/** Exit only after the socket flushes queued frames, so a final signal (sandboxDenial) isn't truncated
 *  by process.exit(). Falls back to a hard timeout if the write never drains. */
function exitAfterFlush(code: number): void {
  const t = setTimeout(() => process.exit(code), 500) as unknown as { unref?: () => void };
  t.unref?.();
  try {
    sock.write(encodeFrame({ kind: "done" }), () => process.exit(code));
  } catch {
    process.exit(code);
  }
}

// Route @invoke/api platform calls (Clipboard.copy, showToast, …) to the host.
let rpcSeq = 0;
const pendingRpc = new Map<number, (r: { result?: unknown; error?: string }) => void>();
__setHostBridge((method, params) => {
  const id = ++rpcSeq;
  return new Promise((resolve, reject) => {
    pendingRpc.set(id, (r) => (r.error ? reject(new Error(r.error)) : resolve(r.result)));
    send({ kind: "rpc", id, method, params });
  });
});

// An async action handler (onAction) that throws rejects AFTER React's synchronous flush, so it lands
// here, not at the invoke site. Mirror Raycast: surface a failure toast and keep the extension alive —
// Node's default is to TERMINATE the process on an unhandled rejection, which would kill the whole
// extension over one failed action. Host RPCs such as runAppleScript reject on error, so an extension
// that doesn't catch (most do) ends up here.
process.on("unhandledRejection", (reason) => {
  const msg = reason instanceof Error ? reason.message : String(reason);
  send({ kind: "log", level: "error", args: ["[unhandledRejection]", msg] });
  void showToast({ style: Toast.Style.Failure, title: "Command failed", message: msg }).catch(() => {});
});

async function main(): Promise<void> {
  // Everything above this line is the trusted runtime (socket, react, reconciler, @invoke/api).
  // From here on the extension is loaded with Node built-ins denied by default — the only path
  // to host capability is the allowlisted RPC above (PLAN.md §4.4). Lock down LAST so infra keeps
  // the access it already acquired, and the untrusted bundle below inherits none of it.
  //
  // EXCEPTION: an extension the user has explicitly TRUSTED (Settings → Extensions → Trust) runs
  // WITHOUT the sandbox — full Node (child_process/fs/net), like Raycast. This is opt-in per extension;
  // everything else stays sandboxed. The host sets INVOKE_TRUSTED=1 only for trusted extensions.
  if (process.env.INVOKE_TRUSTED !== "1") {
    // Wire the virtual filesystem channel (fd 4) BEFORE lockdown, so the fs shim the extension imports
    // has a live, host-mediated, consent-gated `fs` instead of a denied builtin (remediation 01). Captures
    // the real fs.readSync/writeSync now, while they're still reachable.
    const fsReady = installFsSyncBridge();
    if (!fsReady) send({ kind: "log", level: "warn", args: ["[invoke] virtual fs channel unavailable (fd 4)"] });
    lockdown();
  } else {
    send({ kind: "log", level: "warn", args: ["[invoke] running UNSANDBOXED (user-trusted extension)"] });
  }

  const mod = (await import(pathToFileURL(entry).href)) as { default?: unknown };
  const Command = mod.default;
  if (typeof Command !== "function") {
    send({ kind: "log", level: "error", args: [`extension ${entry} has no default export`] });
    process.exit(1);
  }

  // rpcResult must be handled in BOTH modes — a no-view action awaits showHUD/runAppleScript RPCs.
  // searchText/invoke only matter once a view surface exists.
  let surface: ReturnType<typeof createSurface> | null = null;
  let navPop: () => void = () => {}; // assigned once the view surface + nav controller exist
  const decoder = new FrameDecoder();
  sock.on("data", (chunk: Buffer) => {
    for (const raw of decoder.push(chunk)) {
      const msg = raw as ChildBound;
      switch (msg.kind) {
        case "navPop":
          navPop(); // Esc on a pushed view
          break;
        case "rpcResult": {
          const cb = pendingRpc.get(msg.id);
          if (cb) {
            pendingRpc.delete(msg.id);
            cb(msg);
          }
          break;
        }
        case "searchText": {
          const h = surface?.handlerForProp("onSearchTextChange");
          if (h && surface) surface.invokeHandler(h, [msg.text]);
          break;
        }
        case "invoke":
          if (typeof msg.handler === "string" && msg.handler.startsWith("icb-")) __invokeCallback(msg.handler, msg.args);
          else surface?.invokeHandler(msg.handler, msg.args);
          break;
      }
    }
  });

  // Raycast LaunchProps: command arguments (search-bar fields) the host collected, plus launch metadata.
  let launchArguments: Record<string, unknown> = {};
  try { launchArguments = JSON.parse(process.env.INVOKE_ARGUMENTS || "{}"); } catch { launchArguments = {}; }
  // launchContext: data passed by another command via launchCommand({ context }) (Raycast parity).
  let launchContext: Record<string, unknown> = {};
  try { launchContext = JSON.parse(process.env.INVOKE_LAUNCH_CONTEXT || "{}"); } catch { launchContext = {}; }
  const launchProps = { arguments: launchArguments, launchType: process.env.INVOKE_LAUNCH_TYPE || "userInitiated", launchContext, fallbackText: process.env.INVOKE_FALLBACK_TEXT || undefined };

  // ai-tool: run an AI-extension tool's default export with the model-provided input, return its
  // JSON result, then exit. The tool entry is the bundle (Command); input arrives as INVOKE_TOOL_INPUT.
  if (process.env.INVOKE_MODE === "ai-tool") {
    send({ kind: "ready", command: command ?? "" });
    try {
      let input: unknown = {};
      try { input = JSON.parse(process.env.INVOKE_TOOL_INPUT || "{}"); } catch { input = {}; }
      const result = await (Command as (input: unknown) => unknown)(input);
      send({ kind: "aiToolResult", result });
    } catch (e) {
      const denied = sandboxDeniedModule(e);
      if (denied) send({ kind: "sandboxDenial", module: denied });
      send({ kind: "aiToolResult", error: String(e) });
    }
    exitAfterFlush(0);
    return;
  }

  // no-view: run the command's default export as a headless action (no UI), then exit.
  if (process.env.INVOKE_MODE === "no-view") {
    send({ kind: "ready", command: command ?? "" });
    try {
      await (Command as (props: unknown) => unknown)(launchProps);
    } catch (e) {
      const denied = sandboxDeniedModule(e);
      if (denied) send({ kind: "sandboxDenial", module: denied });
      send({ kind: "log", level: "error", args: [String(e)] });
      exitAfterFlush(1);
      return;
    }
    process.exit(0);
  }

  // view: render the component and stream its mutations (each tagged with its navigation frame).
  surface = createSurface({
    onCommit: (commit, ops, frame) => send({ kind: "mutations", commit, ops, frame }),
  });
  // Render-on-push navigation: push(view) mounts `view` as a new frame; pop unwinds. `navDepth` is the
  // stack depth (for the host's back-chevron + Esc routing); the active frame id says which tree to show.
  let navDepth = 0;
  const doPush = (view: ReactNode): void => {
    const frame = surface!.pushFrame(view);
    navDepth++;
    send({ kind: "nav", depth: navDepth, frame });
  };
  navPop = (): void => {
    if (navDepth === 0) return;
    const frame = surface!.popFrame();
    navDepth--;
    send({ kind: "nav", depth: navDepth, frame });
  };
  __setNavController({ push: doPush, pop: navPop });
  surface.render(createElement(Command as React.ComponentType<typeof launchProps>, launchProps));
  send({ kind: "ready", command: command ?? "" });
  sock.on("close", () => process.exit(0));
}

main().catch((e: unknown) => {
  const denied = sandboxDeniedModule(e);
  if (denied) send({ kind: "sandboxDenial", module: denied });
  send({ kind: "log", level: "error", args: [String(e)] });
  exitAfterFlush(1);
});
