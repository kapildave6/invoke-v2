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
import { createElement } from "react";
import { createSurface } from "@invoke/reconciler";
import { __setHostBridge } from "@invoke/api";
import {
  type ChildBound,
  type HostBound,
  encodeFrame,
  FrameDecoder,
} from "@invoke/schema";
import { lockdown } from "./sandbox.ts";

const [entry, command] = process.argv.slice(2);

// fd 3 is a duplex socketpair created by the parent's spawn() stdio config.
const sock = new net.Socket({ fd: 3, readable: true, writable: true });
const send = (msg: HostBound): void => void sock.write(encodeFrame(msg));

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

async function main(): Promise<void> {
  // Everything above this line is the trusted runtime (socket, react, reconciler, @invoke/api).
  // From here on the extension is loaded with Node built-ins denied by default — the only path
  // to host capability is the allowlisted RPC above (PLAN.md §4.4). Lock down LAST so infra keeps
  // the access it already acquired, and the untrusted bundle below inherits none of it.
  lockdown();

  const mod = (await import(pathToFileURL(entry).href)) as { default?: unknown };
  const Command = mod.default;
  if (typeof Command !== "function") {
    send({ kind: "log", level: "error", args: [`extension ${entry} has no default export component`] });
    process.exit(1);
  }

  const surface = createSurface({
    onCommit: (commit, ops) => send({ kind: "mutations", commit, ops }),
  });

  surface.render(createElement(Command as React.FC));
  send({ kind: "ready", command: command ?? "" });

  const decoder = new FrameDecoder();
  sock.on("data", (chunk: Buffer) => {
    for (const raw of decoder.push(chunk)) {
      const msg = raw as ChildBound;
      switch (msg.kind) {
        case "searchText": {
          const h = surface.handlerForProp("onSearchTextChange");
          if (h) surface.invokeHandler(h, [msg.text]);
          break;
        }
        case "invoke":
          surface.invokeHandler(msg.handler, msg.args);
          break;
        case "rpcResult": {
          const cb = pendingRpc.get(msg.id);
          if (cb) {
            pendingRpc.delete(msg.id);
            cb(msg);
          }
          break;
        }
      }
    }
  });
  sock.on("close", () => process.exit(0));
}

main().catch((e: unknown) => {
  send({ kind: "log", level: "error", args: [String(e)] });
  process.exit(1);
});
