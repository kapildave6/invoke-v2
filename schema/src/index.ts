/**
 * @invoke/schema — the single typed contract that crosses the process boundary
 * between the native host (Swift, in production) and the per-extension Node runtime.
 *
 * This is PLAN.md §4.6 (IPC) + §4.5 (the render-mutation stream) made concrete.
 * Keeping it in one package is what lets the Swift side (Codable mirror) and the
 * TS side stay in lockstep — see PLAN.md §8.7 "Lockstep versioning".
 */

export type NodeId = number;

/** The container/root of every surface's view tree. */
export const ROOT: NodeId = 0;

export type SerializedProps = Record<string, unknown>;

/**
 * The render-mutation stream. The reconciler (mutation mode) emits these straight
 * from the React commit phase — we never snapshot-diff the whole tree (PLAN.md §4.5).
 */
export type Mutation =
  | { op: "clearContainer" }
  | { op: "createInstance"; id: NodeId; type: string; props: SerializedProps }
  | { op: "createText"; id: NodeId; text: string }
  | { op: "appendChild"; parent: NodeId; child: NodeId }
  | { op: "insertBefore"; parent: NodeId; child: NodeId; before: NodeId }
  | { op: "removeChild"; parent: NodeId; child: NodeId }
  | { op: "updateProps"; id: NodeId; props: SerializedProps }
  | { op: "updateText"; id: NodeId; text: string };

/**
 * Function props (onAction, onSearchTextChange, …) cannot cross the wire. The
 * reconciler replaces each with a stable reference; the host "calls back" by
 * sending an `invoke` message with this id (PLAN.md §4.4 capability model).
 */
export interface HandlerRef {
  __handler: string;
}
export function isHandlerRef(v: unknown): v is HandlerRef {
  return typeof v === "object" && v !== null && "__handler" in (v as Record<string, unknown>);
}

/** child → host */
export type HostBound =
  | { kind: "ready"; command: string }
  /** `frame` is the navigation frame these ops belong to (0 = base command; >0 = pushed views). */
  | { kind: "mutations"; commit: number; ops: Mutation[]; frame: number }
  /** the active navigation changed. `depth` (0 = base; N = N pushed views) drives the back-chevron and
   *  Esc routing; `frame` is the id of the now-active frame's tree to display. */
  | { kind: "nav"; depth: number; frame: number }
  | { kind: "log"; level: "info" | "warn" | "error"; args: unknown[] }
  /** an extension called a host API (Clipboard.copy, showToast, …) */
  | { kind: "rpc"; id: number; method: string; params: unknown }
  /** a SANDBOXED extension failed because it imported a denied Node built-in (module = e.g. "fs") */
  | { kind: "sandboxDenial"; module: string }
  | { kind: "done" };

/** host → child */
export type ChildBound =
  | { kind: "searchText"; text: string }
  | { kind: "invoke"; handler: string; args: unknown[] }
  /** the user pressed Esc on a pushed view — pop the top navigation frame. */
  | { kind: "navPop" }
  | { kind: "rpcResult"; id: number; result?: unknown; error?: string };

/* --------------------------------------------------------------------------
 * Length-prefixed framing (PLAN.md §4.6): 4-byte big-endian length + UTF-8 JSON.
 * A real impl also caps max-message-size and chunks beyond it, and keeps large
 * binaries OUT of band (content-addressed cache). Kept simple here on purpose.
 * ------------------------------------------------------------------------ */

export const MAX_FRAME_BYTES = 16 * 1024 * 1024;

export function encodeFrame(msg: unknown): Buffer {
  const body = Buffer.from(JSON.stringify(msg), "utf8");
  if (body.length > MAX_FRAME_BYTES) {
    throw new Error(`frame too large: ${body.length} > ${MAX_FRAME_BYTES} (move binaries out-of-band)`);
  }
  const header = Buffer.allocUnsafe(4);
  header.writeUInt32BE(body.length, 0);
  return Buffer.concat([header, body]);
}

/** Stateful stream decoder: feed it chunks, get back whole messages. */
export class FrameDecoder {
  private buf: Buffer = Buffer.alloc(0);

  push(chunk: Buffer): unknown[] {
    this.buf = this.buf.length ? Buffer.concat([this.buf, chunk]) : chunk;
    const out: unknown[] = [];
    while (this.buf.length >= 4) {
      const len = this.buf.readUInt32BE(0);
      if (this.buf.length < 4 + len) break;
      const body = this.buf.subarray(4, 4 + len);
      out.push(JSON.parse(body.toString("utf8")));
      this.buf = this.buf.subarray(4 + len);
    }
    return out;
  }
}
