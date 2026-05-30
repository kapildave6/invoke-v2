/**
 * Extension supervisor (PLAN.md §4.4).
 *
 * The host-side handle to a single running extension process. Forks the child
 * with a dedicated socketpair (fd 3) for framed JSON-RPC, decodes the mutation
 * stream into a view-model tree, and exposes a tiny event surface. A real
 * supervisor also owns the warm pool, crash containment + restart, per-extension
 * resource caps, and the allowlisted host-API router (PLAN.md §4.4/§4.6).
 */
import { spawn, type ChildProcess } from "node:child_process";
import { fileURLToPath } from "node:url";
import path from "node:path";
import { EventEmitter } from "node:events";
import {
  type ChildBound,
  type HostBound,
  encodeFrame,
  FrameDecoder,
} from "@invoke/schema";
import { applyMutations, createViewTree, type ViewTree } from "./viewmodel.ts";

const CHILD = path.join(path.dirname(fileURLToPath(import.meta.url)), "child.ts");

/**
 * The capability allowlist (PLAN.md §4.4/§4.6): the ONLY host methods an extension may invoke.
 * Everything else is rejected with an error reply — denial is enforced HERE by the host, not by
 * convention in the SDK, so even a malicious child that crafts a raw RPC frame gets nothing it
 * isn't granted. Mirrors the surface @invoke/api exposes today; grows in lockstep with the SDK.
 */
export const ALLOWED_RPC: ReadonlySet<string> = new Set([
  "clipboard.copy",
  "clipboard.paste",
  "clipboard.readText",
  "toast.show",
  "hud.show",
  "window.close",
  "preferences.get",
]);

export function isAllowedRpcMethod(method: string): boolean {
  return ALLOWED_RPC.has(method);
}

export interface ExtensionEvents {
  ready: [string];
  commit: [number, ViewTree];
  log: [HostBound & { kind: "log" }];
  rpc: [HostBound & { kind: "rpc" }];
  /** An extension attempted a host method outside the allowlist; it was rejected. */
  denied: [string];
  exit: [number | null];
}

export class ExtensionProcess extends EventEmitter {
  readonly tree: ViewTree = createViewTree();
  private child: ChildProcess;
  private sock: NodeJS.ReadWriteStream;
  private decoder = new FrameDecoder();

  constructor(entry: string, command: string, preferences: Record<string, unknown> = {}) {
    super();
    // process-per-extension: a fresh OS process, isolated address space (§4.4).
    this.child = spawn(
      process.execPath,
      ["--import", "tsx", CHILD, entry, command],
      {
        stdio: ["inherit", "inherit", "inherit", "pipe"], // fd3 = duplex socketpair
        env: { ...process.env, INVOKE_COMMAND: command, INVOKE_PREFERENCES: JSON.stringify(preferences) },
      },
    );
    this.sock = this.child.stdio[3] as unknown as NodeJS.ReadWriteStream;

    this.sock.on("data", (chunk: Buffer) => {
      for (const raw of this.decoder.push(chunk)) this.handle(raw as HostBound);
    });
    this.child.on("exit", (code) => this.emit("exit", code));
  }

  private handle(msg: HostBound): void {
    switch (msg.kind) {
      case "ready":
        this.emit("ready", msg.command);
        break;
      case "mutations":
        if (process.env.INVOKE_DEBUG) console.error(`[commit ${msg.commit}] ${msg.ops.length} ops:`, JSON.stringify(msg.ops));
        applyMutations(this.tree, msg.ops);
        this.emit("commit", msg.commit, this.tree);
        break;
      case "log":
        this.emit("log", msg);
        break;
      case "rpc": {
        // Route every host call through the capability allowlist (§4.4) before performing it.
        this.emit("rpc", msg);
        if (!isAllowedRpcMethod(msg.method)) {
          this.emit("denied", msg.method);
          if (process.env.INVOKE_DEBUG) console.error(`[rpc DENIED] ${msg.method}`);
          this.send({ kind: "rpcResult", id: msg.id, error: `host method not allowed: ${msg.method}` });
          break;
        }
        // A real host performs the capability natively (NSPasteboard, toast, AX…) and replies.
        // Demo: benign stubs so the round-trip and the allowlist are both exercised.
        this.send({ kind: "rpcResult", id: msg.id, result: this.fulfill(msg.method, msg.params) });
        break;
      }
    }
  }

  /** Demo-only native fulfilment of an allowlisted host method (real host: Swift services). */
  private fulfill(method: string, _params: unknown): unknown {
    switch (method) {
      case "clipboard.readText":
        return "";
      default:
        return null;
    }
  }

  send(msg: ChildBound): void {
    this.sock.write(encodeFrame(msg));
  }

  /** Tell the extension the search text changed (host → child event). */
  setSearchText(text: string): void {
    this.send({ kind: "searchText", text });
  }

  /** Trigger an action/handler the host learned about from a serialized prop. */
  invoke(handler: string, args: unknown[] = []): void {
    this.send({ kind: "invoke", handler, args });
  }

  kill(): void {
    this.child.kill();
  }
}
