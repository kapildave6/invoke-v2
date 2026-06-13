// Ambient types for the curated read-only `os` shim (os-safe.mjs). The runtime executes the .mjs via
// tsx untyped; this declaration just lets `import osSafe from "./os-safe.mjs"` typecheck in sandbox.ts.
declare const osSafe: {
  homedir: () => string;
  tmpdir: () => string;
  platform: () => string;
  arch: () => string;
  release: () => string;
  type: () => string;
  version: () => string;
  endianness: () => string;
  totalmem: () => number;
  freemem: () => number;
  uptime: () => number;
  EOL: string;
  constants: typeof import("node:os").constants;
};
export default osSafe;
