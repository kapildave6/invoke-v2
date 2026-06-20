/**
 * Host-side fulfilment of the virtual `fs` channel (fd 4) — the dev-runner half.
 *
 * The macOS app reimplements this in Swift (AppController.handleFS) WITH a per-(extension, directory)
 * consent gate; the dev runner has no GUI to prompt, so it auto-allows and just performs the op. This
 * file is therefore also the canonical spec of the fd-4 wire protocol both hosts must speak:
 *
 *   request : { op, ...params }                       (4-byte BE length + JSON, on fd 4)
 *   reply   : { ...result } | { error, code? }        (same framing)
 *
 * Ops & shapes (paths are absolute, already `~`-expanded by the shim's caller):
 *   read     {path}                      → {base64}
 *   write    {path, base64, flag}        → {ok:true}        flag "w"|"a"
 *   exists   {path}                      → {exists}
 *   readdir  {path}                      → {entries:[{name,file,dir,symlink}]}
 *   stat     {path, lstat?}              → {size,mode,*Ms,isFile,isDirectory,isSymbolicLink,...}
 *   mkdir    {path, recursive}           → {path}
 *   rm       {path, recursive, force, dir?} → {ok:true}
 *   realpath {path}                      → {path}
 *   rename   {from, to}                  → {ok:true}
 *   copyFile {from, to}                  → {ok:true}
 *   mkdtemp  {prefix}                    → {path}
 */
import fs from "node:fs";

export interface FsReply {
  error?: string;
  code?: string;
  [k: string]: unknown;
}

function statReply(p: string, lstat: boolean): FsReply {
  const s = lstat ? fs.lstatSync(p) : fs.statSync(p);
  return {
    size: s.size,
    mode: s.mode,
    uid: s.uid,
    gid: s.gid,
    blksize: s.blksize,
    blocks: s.blocks,
    atimeMs: s.atimeMs,
    mtimeMs: s.mtimeMs,
    ctimeMs: s.ctimeMs,
    birthtimeMs: s.birthtimeMs,
    isFile: s.isFile(),
    isDirectory: s.isDirectory(),
    isSymbolicLink: s.isSymbolicLink(),
  };
}

/** Perform one fs op against the real filesystem (NO consent — dev only). Errors become {error,code}. */
export function fulfillFsOp(req: { op: string } & Record<string, unknown>): FsReply {
  const p = req.path as string;
  try {
    switch (req.op) {
      case "read":
        return { base64: fs.readFileSync(p).toString("base64") };
      case "write":
        fs.writeFileSync(p, Buffer.from((req.base64 as string) ?? "", "base64"), { flag: (req.flag as string) ?? "w" });
        return { ok: true };
      case "exists":
        return { exists: fs.existsSync(p) };
      case "readdir": {
        const entries = fs.readdirSync(p, { withFileTypes: true }).map((e) => ({
          name: e.name,
          file: e.isFile(),
          dir: e.isDirectory(),
          symlink: e.isSymbolicLink(),
        }));
        return { entries };
      }
      case "stat":
        return statReply(p, !!req.lstat);
      case "mkdir": {
        const created = fs.mkdirSync(p, { recursive: !!req.recursive });
        return { path: created ?? p };
      }
      case "rm":
        if (req.dir) fs.rmdirSync(p, { recursive: !!req.recursive });
        else fs.rmSync(p, { recursive: !!req.recursive, force: !!req.force });
        return { ok: true };
      case "realpath":
        return { path: fs.realpathSync(p) };
      case "rename":
        fs.renameSync(req.from as string, req.to as string);
        return { ok: true };
      case "copyFile":
        fs.copyFileSync(req.from as string, req.to as string);
        return { ok: true };
      case "mkdtemp":
        return { path: fs.mkdtempSync((req.prefix as string) ?? "") };
      default:
        return { error: `[invoke:fs] unknown op "${req.op}"`, code: "EINVAL" };
    }
  } catch (e) {
    const err = e as NodeJS.ErrnoException;
    return { error: err.message ?? String(e), code: err.code };
  }
}
