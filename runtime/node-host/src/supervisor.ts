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
import fs from "node:fs";
import path from "node:path";
import { EventEmitter } from "node:events";
import {
  type ChildBound,
  type HostBound,
  encodeFrame,
  FrameDecoder,
} from "@invoke/schema";
import { applyMutations, createViewTree, type ViewTree } from "./viewmodel.ts";
import { fulfillFsOp } from "./fs-host.ts";

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
  "open",
  "localStorage.getItem",
  "localStorage.setItem",
  "localStorage.removeItem",
  "localStorage.clear",
  "localStorage.allItems",
  "runAppleScript",
  "executeSQL",
  "confirmAlert",
  "preferences.open",
  "captureException",
  "cache.set",
  "cache.remove",
  "cache.clear",
  "cache.allItems",
  // selection / application / finder / filesystem APIs (remediation 04)
  "selection.read",
  "app.list",
  "app.frontmost",
  "app.default",
  "finder.reveal",
  "finder.selection",
  "fs.trash",
  "ai.ask", // Raycast AI.ask / useAI (host Anthropic client)
  "browser.getTabs",   // Raycast BrowserExtension.getTabs (host AppleScript)
  "browser.getContent", // Raycast BrowserExtension.getContent (host AppleScript)
  // OAuth (PKCE) — host owns PKCE crypto, browser/redirect, and per-extension Keychain token storage.
  "oauth.authorizeRequest", "oauth.authorize", "oauth.setTokens", "oauth.getTokens", "oauth.removeTokens",
  "command.updateMetadata",
  "command.launch", // launchCommand(): launch another command (same or named extension)
  // Real implementations of previously-degraded Action/Clipboard members:
  "quicklink.create",   // Action.CreateQuicklink → Invoke quicklink store
  "snippet.create",     // Action.CreateSnippet → Invoke snippet store
  "clipboard.read",     // Clipboard.read() → { text, file, html }
  "clipboard.clear",    // Clipboard.clear() → clears the general pasteboard
  "quicklook.preview",  // Action.ToggleQuickLook → macOS Quick Look (qlmanage)
  "open.with",          // Action.OpenWith → choose an app and open
  "date.pick",          // Action.PickDate → native NSDatePicker, returns the chosen date
  "windowManagement.getActiveWindow",
  "windowManagement.getWindowsOnActiveDesktop",
  "windowManagement.setWindowBounds",
  "windowManagement.getDesktops",
]);

export function isAllowedRpcMethod(method: string): boolean {
  return ALLOWED_RPC.has(method);
}

/**
 * Native fulfilment of an allowlisted host capability. The macOS app provides a Swift implementation
 * (NSPasteboard, NSWorkspace.open, …); the dev runner (run.ts) provides a Node one. May be async.
 */
export type HostCapabilities = (method: string, params: unknown) => unknown | Promise<unknown>;

export interface ExtensionEvents {
  ready: [string];
  commit: [number, ViewTree];
  log: [HostBound & { kind: "log" }];
  rpc: [HostBound & { kind: "rpc" }];
  /** An extension attempted a host method outside the allowlist; it was rejected. */
  denied: [string];
  /** A sandboxed extension failed because it imported a denied Node built-in (arg: module name). */
  sandboxDenial: [string];
  /** The active navigation frame changed (args: depth, active frame id). */
  nav: [number, number];
  /** An AI-extension tool finished (mode "ai-tool"): result or error. */
  aiToolResult: [{ result?: unknown; error?: string }];
  exit: [number | null];
}

export class ExtensionProcess extends EventEmitter {
  readonly tree: ViewTree = createViewTree(); // base navigation frame (frame 0)
  private frameTrees = new Map<number, ViewTree>([[0, this.tree]]); // render-on-push frames
  private activeFrame = 0;
  private child: ChildProcess;
  private sock: NodeJS.ReadWriteStream;
  private decoder = new FrameDecoder();
  private fsSock?: NodeJS.ReadWriteStream;
  private fsDecoder = new FrameDecoder();
  private capabilities?: HostCapabilities;

  constructor(entry: string, command: string, preferences: Record<string, unknown> = {}, capabilities?: HostCapabilities) {
    super();
    this.capabilities = capabilities;
    // Point tsx at the EXTENSION's tsconfig (entry = <extDir>/src/<cmd>.tsx → <extDir>/tsconfig.json) so
    // its `@/*` → `src/*` path alias resolves; otherwise tsx picks the repo-root tsconfig (cwd) and `@/x`
    // fails with "Cannot find module". Only set it when that tsconfig exists.
    const extTsconfig = path.join(path.dirname(path.dirname(entry)), "tsconfig.json");
    const tsconfigEnv = fs.existsSync(extTsconfig) ? { TSX_TSCONFIG_PATH: extTsconfig } : {};
    // process-per-extension: a fresh OS process, isolated address space (§4.4).
    this.child = spawn(
      process.execPath,
      ["--import", "tsx", CHILD, entry, command],
      {
        stdio: ["inherit", "inherit", "inherit", "pipe", "pipe"], // fd3 = RPC; fd4 = synchronous fs channel
        env: { ...process.env, ...tsconfigEnv, INVOKE_COMMAND: command, INVOKE_PREFERENCES: JSON.stringify(preferences) },
      },
    );
    this.sock = this.child.stdio[3] as unknown as NodeJS.ReadWriteStream;

    this.sock.on("data", (chunk: Buffer) => {
      for (const raw of this.decoder.push(chunk)) this.handle(raw as HostBound);
    });

    // fd 4: the child blocks on each virtual-fs op; we perform it and frame back a reply. The dev runner
    // auto-allows (no GUI to prompt) — the macOS host gates the same protocol per (extension, directory).
    this.fsSock = this.child.stdio[4] as unknown as NodeJS.ReadWriteStream | undefined;
    this.fsSock?.on("data", (chunk: Buffer) => {
      for (const raw of this.fsDecoder.push(chunk)) {
        const reply = fulfillFsOp(raw as { op: string } & Record<string, unknown>);
        this.fsSock?.write(encodeFrame(reply));
      }
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
        {
          const frame = (msg as HostBound & { frame?: number }).frame ?? 0;
          let ft = this.frameTrees.get(frame);
          if (!ft) { ft = createViewTree(); this.frameTrees.set(frame, ft); }
          applyMutations(ft, msg.ops);
          // Emit the ACTIVE frame's tree so consumers always render what's on top.
          this.emit("commit", msg.commit, this.frameTrees.get(this.activeFrame) ?? this.tree);
        }
        break;
      case "log":
        this.emit("log", msg);
        break;
      case "sandboxDenial":
        // Mirror of the Swift host: a sandboxed child needs full Node access. The macOS host offers
        // "Trust & relaunch"; the dev runner just surfaces it (see run.ts).
        this.emit("sandboxDenial", (msg as HostBound & { module?: string }).module ?? "a Node built-in");
        break;
      case "aiToolResult": {
        const m = msg as HostBound & { result?: unknown; error?: string };
        this.emit("aiToolResult", { result: m.result, error: m.error });
        break;
      }
      case "nav": {
        // Render-on-push: the active navigation frame changed; show that frame's tree.
        const navMsg = msg as HostBound & { depth?: number; frame?: number };
        this.activeFrame = navMsg.frame ?? 0;
        this.emit("nav", navMsg.depth ?? 0, this.activeFrame);
        this.emit("commit", 0, this.frameTrees.get(this.activeFrame) ?? this.tree);
        break;
      }
      case "rpc": {
        // Route every host call through the capability allowlist (§4.4) before performing it.
        this.emit("rpc", msg);
        if (!isAllowedRpcMethod(msg.method)) {
          this.emit("denied", msg.method);
          if (process.env.INVOKE_DEBUG) console.error(`[rpc DENIED] ${msg.method}`);
          this.send({ kind: "rpcResult", id: msg.id, error: `host method not allowed: ${msg.method}` });
          break;
        }
        // The host performs the capability (Swift services natively, or the dev runner's Node impl)
        // and replies. Fulfilment may be async; errors come back as an rpc error.
        Promise.resolve()
          .then(() => (this.capabilities ?? this.fulfill)(msg.method, msg.params))
          .then((result) => this.send({ kind: "rpcResult", id: msg.id, result }))
          .catch((err: unknown) => this.send({ kind: "rpcResult", id: msg.id, error: String(err) }));
        break;
      }
    }
  }

  /** Fallback fulfilment when no capabilities are injected (benign stubs). */
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
