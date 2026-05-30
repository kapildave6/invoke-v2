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

export async function resolve(specifier, context, nextResolve) {
  if (isDeniedBuiltin(specifier)) {
    throw new Error(
      `[invoke:sandbox] import of Node built-in "${specifier}" is denied — ` +
        `extensions reach host capabilities only via the @invoke/api RPC allowlist (PLAN.md §4.4)`,
    );
  }
  return nextResolve(specifier, context);
}
