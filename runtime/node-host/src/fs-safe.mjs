/**
 * Virtual `fs` shim — the extension-facing half of the filesystem capability
 * (remediation 01, Option A1). An extension's `import … from "fs"` resolves HERE
 * (deny-loader.mjs / sandbox.ts `_load`) instead of being denied.
 *
 * Every operation is one synchronous round-trip to the host over fd 4 via
 * `globalThis.__invokeFsSync__` (installed by fs-bridge.ts before lockdown). The
 * host canonicalizes the path, consent-gates it per (extension, directory), performs
 * the real op, and replies. So the child never holds OS filesystem authority — it
 * asks a host that does, exactly like the `executeSQL` capability, just with a
 * filesystem verb set. The sync API is faithful because fd 4 blocks until the reply.
 *
 * Imports nothing (only the `Buffer` global) so it loads cleanly under the sandbox.
 */

/** @returns {import("./fs-bridge.ts").FsResult} */
function call(op, params) {
  const bridge = globalThis.__invokeFsSync__;
  if (typeof bridge !== "function") {
    const e = new Error(`[invoke:fs] filesystem is not available (no host fs channel) — op "${op}"`);
    e.code = "EPERM";
    throw e;
  }
  return bridge(op, params ?? {});
}

const toPathString = (p) => (p instanceof URL ? decodeURIComponent(p.pathname) : String(p));

/** Normalize the `options` arg shared by readFile/writeFile (string = encoding, or an object). */
function opts(options) {
  if (typeof options === "string") return { encoding: options };
  return options && typeof options === "object" ? options : {};
}

/** A Stats-like object from the host's plain reply (with the predicate methods extensions call). */
function makeStats(s) {
  const mk = (ms) => new Date(ms ?? 0);
  return {
    size: s.size ?? 0,
    mode: s.mode ?? 0,
    uid: s.uid ?? 0,
    gid: s.gid ?? 0,
    blksize: s.blksize ?? 4096,
    blocks: s.blocks ?? 0,
    atimeMs: s.atimeMs ?? 0,
    mtimeMs: s.mtimeMs ?? 0,
    ctimeMs: s.ctimeMs ?? 0,
    birthtimeMs: s.birthtimeMs ?? 0,
    atime: mk(s.atimeMs),
    mtime: mk(s.mtimeMs),
    ctime: mk(s.ctimeMs),
    birthtime: mk(s.birthtimeMs),
    isFile: () => !!s.isFile,
    isDirectory: () => !!s.isDirectory,
    isSymbolicLink: () => !!s.isSymbolicLink,
    isBlockDevice: () => false,
    isCharacterDevice: () => false,
    isFIFO: () => false,
    isSocket: () => false,
  };
}

/** A Dirent-like object (readdir withFileTypes:true). */
function makeDirent(e, parentPath) {
  return {
    name: e.name,
    parentPath,
    path: parentPath,
    isFile: () => !!e.file,
    isDirectory: () => !!e.dir,
    isSymbolicLink: () => !!e.symlink,
    isBlockDevice: () => false,
    isCharacterDevice: () => false,
    isFIFO: () => false,
    isSocket: () => false,
  };
}

// ---- core synchronous ops (everything else is built on these) ----

function readFileSync(path, options) {
  const o = opts(options);
  const { base64 } = call("read", { path: toPathString(path) });
  const buf = Buffer.from(base64 ?? "", "base64");
  return o.encoding ? buf.toString(o.encoding) : buf;
}

function toBuffer(data, encoding) {
  if (Buffer.isBuffer(data)) return data;
  if (data instanceof Uint8Array) return Buffer.from(data);
  if (data instanceof ArrayBuffer) return Buffer.from(new Uint8Array(data));
  return Buffer.from(String(data), encoding || "utf8");
}

function writeFileSync(path, data, options) {
  const o = opts(options);
  const buf = toBuffer(data, o.encoding);
  call("write", { path: toPathString(path), base64: buf.toString("base64"), flag: o.flag ?? "w" });
}

function appendFileSync(path, data, options) {
  const o = opts(options);
  const buf = toBuffer(data, o.encoding);
  call("write", { path: toPathString(path), base64: buf.toString("base64"), flag: "a" });
}

function existsSync(path) {
  try {
    return !!call("exists", { path: toPathString(path) }).exists;
  } catch {
    return false;
  }
}

function accessSync(path) {
  if (!call("exists", { path: toPathString(path) }).exists) {
    const e = new Error(`ENOENT: no such file or directory, access '${toPathString(path)}'`);
    e.code = "ENOENT";
    throw e;
  }
}

function readdirSync(path, options) {
  const o = opts(options);
  const p = toPathString(path);
  const { entries = [] } = call("readdir", { path: p });
  if (o.withFileTypes) return entries.map((e) => makeDirent(e, p));
  return entries.map((e) => e.name);
}

function statSync(path) {
  return makeStats(call("stat", { path: toPathString(path) }));
}
function lstatSync(path) {
  return makeStats(call("stat", { path: toPathString(path), lstat: true }));
}

function mkdirSync(path, options) {
  const o = opts(options);
  const r = call("mkdir", { path: toPathString(path), recursive: !!o.recursive });
  return r.path; // Node returns the first created dir when recursive
}

function rmSync(path, options) {
  const o = opts(options);
  call("rm", { path: toPathString(path), recursive: !!o.recursive, force: !!o.force });
}
function unlinkSync(path) {
  call("rm", { path: toPathString(path), recursive: false, force: false });
}
function rmdirSync(path, options) {
  const o = opts(options);
  call("rm", { path: toPathString(path), recursive: !!o.recursive, force: false, dir: true });
}

function realpathSync(path) {
  return call("realpath", { path: toPathString(path) }).path;
}
realpathSync.native = realpathSync;

function renameSync(from, to) {
  call("rename", { from: toPathString(from), to: toPathString(to) });
}
function copyFileSync(from, to) {
  call("copyFile", { from: toPathString(from), to: toPathString(to) });
}
function mkdtempSync(prefix) {
  return call("mkdtemp", { prefix: toPathString(prefix) }).path;
}

// ---- callback wrappers (err-first; fire after the blocking call) ----

/** Turn a sync fn into a Node callback-style fn: last arg is the callback, the one before may be options. */
function asCallback(syncFn, resultArg = true) {
  return (...args) => {
    const cb = args.pop();
    if (typeof cb !== "function") throw new TypeError("callback is not a function");
    try {
      const r = syncFn(...args);
      queueMicrotask(() => (resultArg ? cb(null, r) : cb(null)));
    } catch (e) {
      queueMicrotask(() => cb(e));
    }
  };
}

const readFile = asCallback(readFileSync);
const writeFile = asCallback(writeFileSync, false);
const appendFile = asCallback(appendFileSync, false);
const readdir = asCallback(readdirSync);
const stat = asCallback(statSync);
const lstat = asCallback(lstatSync);
const mkdir = asCallback(mkdirSync);
const rm = asCallback(rmSync, false);
const unlink = asCallback(unlinkSync, false);
const rmdir = asCallback(rmdirSync, false);
const realpath = asCallback(realpathSync);
const rename = asCallback(renameSync, false);
const copyFile = asCallback(copyFileSync, false);
const access = asCallback(accessSync, false);
const exists = (path, cb) => queueMicrotask(() => cb(existsSync(path))); // legacy: single boolean arg

// ---- promises ----

const promises = {
  readFile: (p, o) => Promise.resolve().then(() => readFileSync(p, o)),
  writeFile: (p, d, o) => Promise.resolve().then(() => writeFileSync(p, d, o)),
  appendFile: (p, d, o) => Promise.resolve().then(() => appendFileSync(p, d, o)),
  readdir: (p, o) => Promise.resolve().then(() => readdirSync(p, o)),
  stat: (p) => Promise.resolve().then(() => statSync(p)),
  lstat: (p) => Promise.resolve().then(() => lstatSync(p)),
  mkdir: (p, o) => Promise.resolve().then(() => mkdirSync(p, o)),
  rm: (p, o) => Promise.resolve().then(() => rmSync(p, o)),
  unlink: (p) => Promise.resolve().then(() => unlinkSync(p)),
  rmdir: (p, o) => Promise.resolve().then(() => rmdirSync(p, o)),
  realpath: (p) => Promise.resolve().then(() => realpathSync(p)),
  rename: (a, b) => Promise.resolve().then(() => renameSync(a, b)),
  copyFile: (a, b) => Promise.resolve().then(() => copyFileSync(a, b)),
  mkdtemp: (p) => Promise.resolve().then(() => mkdtempSync(p)),
  access: (p) => Promise.resolve().then(() => accessSync(p)),
};

// ---- streams (buffered degrade: fine for the read-whole-file / write-whole-file pattern) ----

function createReadStream(path) {
  // Minimal Readable: emit the whole file once, then end. Covers hashing/upload-by-stream usage.
  const listeners = { data: [], end: [], error: [], close: [] };
  const stream = {
    on(ev, fn) {
      (listeners[ev] ??= []).push(fn);
      return stream;
    },
    once(ev, fn) {
      return stream.on(ev, fn);
    },
    pipe(dest) {
      stream.on("data", (c) => dest.write?.(c));
      stream.on("end", () => dest.end?.());
      return dest;
    },
    destroy() {},
  };
  queueMicrotask(() => {
    try {
      const buf = readFileSync(path);
      for (const fn of listeners.data) fn(buf);
      for (const fn of listeners.end) fn();
      for (const fn of listeners.close) fn();
    } catch (e) {
      for (const fn of listeners.error) fn(e);
    }
  });
  return stream;
}

const constants = { F_OK: 0, R_OK: 4, W_OK: 2, X_OK: 1, COPYFILE_EXCL: 1 };

const api = {
  readFileSync, writeFileSync, appendFileSync, existsSync, accessSync,
  readdirSync, statSync, lstatSync, mkdirSync, rmSync, unlinkSync, rmdirSync,
  realpathSync, renameSync, copyFileSync, mkdtempSync,
  readFile, writeFile, appendFile, readdir, stat, lstat, mkdir, rm, unlink,
  rmdir, realpath, rename, copyFile, access, exists,
  createReadStream,
  promises, constants,
};

export {
  readFileSync, writeFileSync, appendFileSync, existsSync, accessSync,
  readdirSync, statSync, lstatSync, mkdirSync, rmSync, unlinkSync, rmdirSync,
  realpathSync, renameSync, copyFileSync, mkdtempSync,
  readFile, writeFile, appendFile, readdir, stat, lstat, mkdir, rm, unlink,
  rmdir, realpath, rename, copyFile, access, exists,
  createReadStream, promises, constants,
};
export default api;
