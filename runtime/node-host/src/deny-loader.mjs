/**
 * ESM module-customization hook — the import side of extension isolation (PLAN.md §4.4).
 *
 * "Node built-ins denied by default": an extension reaches host capabilities ONLY
 * through the allowlisted @invoke/api RPC, never by importing `fs`/`net`/`child_process`
 * directly. This hook is registered (via sandbox.ts → module.register) AFTER the child's
 * privileged infrastructure has loaded and right BEFORE the untrusted bundle is imported,
 * so it constrains the extension's module graph but not the runtime that hosts it.
 *
 * Plain `.mjs` on purpose: it loads in Node's hooks thread without needing tsx/TS
 * transpilation, and it imports only Node builtins + the shared policy JSON.
 *
 * SINGLE SOURCE OF TRUTH: the allowlist lives in safe-builtins.json and is imported by
 * BOTH this hook (the ESM side) and sandbox.ts (the CJS Module._load patch), so the two
 * module systems enforce the exact same policy with no drift.
 */
import { builtinModules } from "node:module";
import SAFE_LIST from "./safe-builtins.json" with { type: "json" };

/**
 * Pure-compute / data builtins that grant no ambient OS authority (no fs/net/exec).
 * `process` is included because it is a global regardless of import; its dangerous bits
 * (binding/dlopen) are neutered on the shared object in sandbox.ts, so gating the import is moot.
 */
export const SAFE_BUILTINS = new Set(SAFE_LIST);

/** True if `specifier` resolves to a core builtin that is NOT on the safe allowlist. */
export function isDeniedBuiltin(specifier) {
  const hasNodePrefix = specifier.startsWith("node:");
  const name = hasNodePrefix ? specifier.slice(5) : specifier;
  const isBuiltin = hasNodePrefix || builtinModules.includes(name);
  if (!isBuiltin) return false;
  return !SAFE_BUILTINS.has(name);
}

/** Our curated read-only `os` shim. An extension's `import … from "os"` resolves HERE instead of being
 *  denied; the shim itself is the only module allowed to import the real `node:os`. */
const OS_SAFE_URL = new URL("./os-safe.mjs", import.meta.url).href;
/** Compat shim for the `run-applescript` npm package (it shells out via child_process). */
const RUN_APPLESCRIPT_URL = new URL("./run-applescript-shim.mjs", import.meta.url).href;
/** Virtual filesystem shims — host-mediated, consent-gated `fs` / `fs/promises` (remediation 01). */
const FS_SAFE_URL = new URL("./fs-safe.mjs", import.meta.url).href;
const FS_PROMISES_SAFE_URL = new URL("./fs-promises-safe.mjs", import.meta.url).href;

export async function resolve(specifier, context, nextResolve) {
  const name = specifier.startsWith("node:") ? specifier.slice(5) : specifier;
  if (name === "os") {
    // The shim reaching for the real os is allowed; everyone else gets the curated subset.
    if (context.parentURL === OS_SAFE_URL) return nextResolve(specifier, context);
    return { url: OS_SAFE_URL, shortCircuit: true };
  }
  if (name === "fs" || name === "fs/promises") {
    // The promises shim reaching INTO fs-safe is the one allowed import of the family; the extension
    // gets the virtual shim that forwards every op to the host's consent-gated fs channel.
    if (context.parentURL === FS_SAFE_URL) return nextResolve(specifier, context);
    return { url: name === "fs/promises" ? FS_PROMISES_SAFE_URL : FS_SAFE_URL, shortCircuit: true };
  }
  if (specifier === "run-applescript") {
    return { url: RUN_APPLESCRIPT_URL, shortCircuit: true };
  }
  if (isDeniedBuiltin(specifier)) {
    throw new Error(
      `[invoke:sandbox] import of Node built-in "${specifier}" is denied — ` +
        `extensions reach host capabilities only via the @invoke/api RPC allowlist (PLAN.md §4.4)`,
    );
  }
  return nextResolve(specifier, context);
}
