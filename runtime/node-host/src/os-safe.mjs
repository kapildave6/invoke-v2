/**
 * Curated read-only subset of `node:os` exposed to sandboxed extensions (PLAN.md §4.4).
 *
 * The sandbox denies `os` by default. This shim is what an extension's `import ... from "os"` is
 * REDIRECTED to (see deny-loader.mjs), exposing only the read-only system-info calls extensions
 * legitimately need (e.g. homedir() to locate a database). Deliberately OMITTED, as identity /
 * fingerprinting surface an unreviewed extension has no business reading under Invoke's
 * data-protection posture:
 *   - userInfo()          username / uid / gid / homedir
 *   - networkInterfaces() IP / MAC addresses
 *   - hostname()          the computer name (Macs default to "<FirstName>'s MacBook" -> PII)
 *   - cpus()              CPU model/speed (device fingerprint)
 * The shim itself (and only the shim) is allowed to import the real os.
 */
import os from "node:os";

export const homedir = () => os.homedir();
export const tmpdir = () => os.tmpdir();
export const platform = () => os.platform();
export const arch = () => os.arch();
export const release = () => os.release();
export const type = () => os.type();
export const version = () => os.version();
export const endianness = () => os.endianness();
export const totalmem = () => os.totalmem();
export const freemem = () => os.freemem();
export const uptime = () => os.uptime();
export const EOL = os.EOL;
export const constants = os.constants;

export default {
  homedir,
  tmpdir,
  platform,
  arch,
  release,
  type,
  version,
  endianness,
  totalmem,
  freemem,
  uptime,
  EOL,
  constants,
};
