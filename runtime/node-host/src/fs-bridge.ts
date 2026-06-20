/**
 * Synchronous filesystem bridge — the runtime half of the virtual `fs` capability
 * (remediation 01, Option A1).
 *
 * The async RPC bridge (fd 3, `__invokeHostRpc__`) cannot serve `readFileSync` &
 * friends: it rides a non-blocking `net.Socket` and resolves on a later event-loop
 * turn, but a sandboxed extension calling `fs.readFileSync(...)` needs the bytes
 * *before the call returns*. So fs gets its OWN channel on **fd 4**: a blocking
 * socketpair the host answers synchronously. We capture the REAL `fs.readSync` /
 * `fs.writeSync` here (this module loads as trusted infra, BEFORE `lockdown()`), and
 * the fs shim (`fs-safe.mjs`) does every op as one framed request → blocking response
 * round-trip through `globalThis.__invokeFsSync__`. The host mediates + consent-gates
 * every path, so the default-deny sandbox is preserved — the child never touches the
 * real filesystem, only a host that does on its behalf.
 *
 * fd 4 is NEVER wrapped in a `net.Socket`, so it stays in blocking mode: `readSync`
 * blocks the child's thread until the host replies (exactly the semantics `*Sync`
 * needs). The child has nothing else to do meanwhile — it is waiting on a file.
 */
import fs from "node:fs";
import { encodeFrame } from "@invoke/schema";

/** A host fs reply: a result object, or an error carrying an errno `code` the shim re-throws. */
export interface FsResult {
  error?: string;
  code?: string;
  [k: string]: unknown;
}

/** The synchronous host call the fs shim uses: send `{op, ...params}`, block for the reply. */
export type FsSyncCall = (op: string, params: Record<string, unknown>) => FsResult;

declare global {
  // eslint-disable-next-line no-var
  var __invokeFsSync__: FsSyncCall | undefined;
}

const FS_FD = 4;

/**
 * Install `globalThis.__invokeFsSync__` over fd 4 if that fd is a live socket. Returns true if the
 * bridge is wired (sandboxed children spawned by a host), false otherwise (e.g. fd 4 absent) — in
 * which case the fs shim will throw a clear error rather than hang.
 */
export function installFsSyncBridge(): boolean {
  // Bail unless fd 4 is actually open — otherwise readSync/writeSync would throw EBADF on first use.
  try {
    fs.fstatSync(FS_FD);
  } catch {
    return false;
  }

  // Captured from the REAL fs, before lockdown denies it to the extension bundle.
  const readSync = fs.readSync.bind(fs);
  const writeSync = fs.writeSync.bind(fs);

  let leftover: Buffer = Buffer.alloc(0);

  // fd 4 is a blocking socket when the macOS host spawns us (socketpair → blocking), but Node's
  // child_process "pipe" (the dev runner) may hand the child a NON-blocking fd, where readSync/writeSync
  // throw EAGAIN before data is ready. Sleep ~1ms via Atomics.wait (no busy spin) and retry, so the same
  // bridge is correct under both spawners. A blocking fd simply never hits this path.
  const SLEEP = new Int32Array(new SharedArrayBuffer(4));
  const isAgain = (e: unknown): boolean => {
    const code = (e as { code?: string })?.code;
    return code === "EAGAIN" || code === "EWOULDBLOCK";
  };
  const napAndRetry = <T>(fn: () => T): T => {
    for (;;) {
      try {
        return fn();
      } catch (e) {
        if (!isAgain(e)) throw e;
        Atomics.wait(SLEEP, 0, 0, 1); // ~1ms, then poll again
      }
    }
  };

  const writeAll = (buf: Buffer): void => {
    let off = 0;
    while (off < buf.length) {
      off += napAndRetry(() => writeSync(FS_FD, buf, off, buf.length - off, null));
    }
  };

  // Block until one whole length-prefixed frame (4-byte BE length + JSON) has arrived on fd 4.
  const readFrame = (): FsResult => {
    for (;;) {
      if (leftover.length >= 4) {
        const len = leftover.readUInt32BE(0);
        if (leftover.length >= 4 + len) {
          const body = leftover.subarray(4, 4 + len);
          const rest = Buffer.from(leftover.subarray(4 + len)); // detach so the next read can't alias
          leftover = rest;
          return JSON.parse(body.toString("utf8")) as FsResult;
        }
      }
      const chunk = Buffer.allocUnsafe(1 << 16);
      const n = napAndRetry(() => readSync(FS_FD, chunk, 0, chunk.length, null));
      if (n === 0) throw new Error("[invoke:fs] host closed the filesystem channel");
      const slice = chunk.subarray(0, n);
      leftover = leftover.length ? Buffer.concat([leftover, slice]) : Buffer.from(slice);
    }
  };

  globalThis.__invokeFsSync__ = (op, params) => {
    writeAll(encodeFrame({ op, ...params }));
    const res = readFrame();
    if (res && typeof res.error === "string") {
      const e = new Error(res.error) as Error & { code?: string };
      if (typeof res.code === "string") e.code = res.code;
      throw e;
    }
    return res;
  };
  return true;
}
