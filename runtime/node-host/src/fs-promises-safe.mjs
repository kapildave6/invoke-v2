/**
 * Virtual `fs/promises` shim. An extension's `import { readFile } from "fs/promises"`
 * (or `import fs from "fs/promises"`) resolves HERE. It is just the promise surface of
 * fs-safe.mjs hoisted to top-level named exports, so both import shapes work.
 */
import { promises } from "./fs-safe.mjs";

export const readFile = promises.readFile;
export const writeFile = promises.writeFile;
export const appendFile = promises.appendFile;
export const readdir = promises.readdir;
export const stat = promises.stat;
export const lstat = promises.lstat;
export const mkdir = promises.mkdir;
export const rm = promises.rm;
export const unlink = promises.unlink;
export const rmdir = promises.rmdir;
export const realpath = promises.realpath;
export const rename = promises.rename;
export const copyFile = promises.copyFile;
export const mkdtemp = promises.mkdtemp;
export const access = promises.access;

export default promises;
