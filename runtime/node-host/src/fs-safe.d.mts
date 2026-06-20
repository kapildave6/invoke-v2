// Ambient types for the virtual `fs` shim (fs-safe.mjs). The runtime executes the .mjs via tsx
// untyped; this declaration just lets `import fsSafe from "./fs-safe.mjs"` typecheck in sandbox.ts.
// Shaped loosely (the real surface is large and dynamically built); `unknown` keeps callers honest.
declare const fsSafe: {
  promises: Record<string, (...args: unknown[]) => Promise<unknown>>;
  constants: Record<string, number>;
  [k: string]: unknown;
};
export default fsSafe;
