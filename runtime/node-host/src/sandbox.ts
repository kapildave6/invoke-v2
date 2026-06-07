/**
 * Extension sandbox — "Node built-ins denied by default" (PLAN.md §4.4).
 *
 * `lockdown()` is the runtime half of isolation: process-per-extension gives address-space
 * separation; this denies the capability surface *inside* that process so the only path to
 * the host is the allowlisted RPC. It closes three escape routes:
 *
 *   1. ESM `import`            — a module.register() resolve hook (deny-loader.mjs)
 *   2. CJS `require`           — a Module._load patch (transitive CJS deps that require fs/net)
 *   3. native bindings         — process.binding / _linkedBinding / dlopen neutered
 *
 * Call it AFTER the child's privileged infra (net socket, react, reconciler, @invoke/api)
 * has loaded and BEFORE importing the untrusted bundle, so only the extension is constrained.
 * Production hardens this further with a macOS seatbelt/App-Sandbox profile on the child (§4.4).
 *
 * The allowlist is the SAME policy file the ESM hook (deny-loader.mjs) imports — single
 * source of truth, so the CJS and ESM gates can never drift apart.
 */
import Module, { register, isBuiltin } from "node:module";
import SAFE_LIST from "./safe-builtins.json" with { type: "json" };
import osSafe from "./os-safe.mjs";

/** Pure-compute / data builtins that grant no ambient OS authority (no fs/net/exec). */
const SAFE_BUILTINS = new Set<string>(SAFE_LIST);

/** The curated read-only `os` shim (see os-safe.mjs) shaped for CJS require(): named methods AND a
 *  `default` for esModuleInterop's transpiled `import os from "os"` -> require("os").default. Captured
 *  at module load (before lockdown), so reaching the real node:os here is allowed. */
const CURATED_OS_CJS: Record<string, unknown> = { ...(osSafe as Record<string, unknown>), default: osSafe };

function isDeniedBuiltin(request: string): boolean {
  const hasNodePrefix = request.startsWith("node:");
  const name = hasNodePrefix ? request.slice(5) : request;
  if (!hasNodePrefix && !isBuiltin(request)) return false;
  return !SAFE_BUILTINS.has(name);
}

let installed = false;

/** Lock the current process down so the extension cannot reach denied OS capabilities. */
export function lockdown(): void {
  if (installed) return;
  installed = true;

  // (3) Native-binding escape hatches reachable from the global `process`. Fail CLOSED:
  // if any one cannot be neutered, lockdown throws and the extension is never loaded — we
  // never silently proceed with a hole (the prior best-effort try/catch could have).
  const proc = process as unknown as Record<string, unknown>;
  for (const name of ["binding", "_linkedBinding", "dlopen"]) {
    const deny = (): never => {
      throw new Error(`[invoke:sandbox] process.${name} is denied (PLAN.md §4.4)`);
    };
    try {
      Object.defineProperty(proc, name, { value: deny, writable: false, configurable: false });
    } catch {
      // Non-configurable on this runtime — fall back to direct assignment, then verify below.
      try {
        proc[name] = deny;
      } catch {
        /* verified next */
      }
    }
    if (proc[name] !== deny) {
      throw new Error(`[invoke:sandbox] lockdown FAILED: could not neuter process.${name} (fail-closed)`);
    }
  }

  // process.report.getReport() returns host diagnostics — hostname, CPU model, and every network
  // interface's MAC/IP — i.e. exactly the identity/fingerprinting surface the curated `os` shim
  // withholds (userInfo/networkInterfaces/hostname/cpus). Neuter the report API too, fail-closed, or
  // the shim is trivially bypassed (PLAN.md §4.4).
  const report = proc.report as Record<string, unknown> | undefined;
  if (report) {
    for (const name of ["getReport", "writeReport", "triggerReport"]) {
      const deny = (): never => {
        throw new Error(`[invoke:sandbox] process.report.${name} is denied (PLAN.md §4.4)`);
      };
      try {
        Object.defineProperty(report, name, { value: deny, writable: false, configurable: false });
      } catch {
        try {
          report[name] = deny;
        } catch {
          /* verified next */
        }
      }
      if (report[name] !== deny) {
        throw new Error(`[invoke:sandbox] lockdown FAILED: could not neuter process.report.${name} (fail-closed)`);
      }
    }
  }

  // (2) CJS require(): catches transitive CommonJS deps that try to require a builtin.
  // ESM `import` of `node:module` is already denied, so the extension cannot mint a fresh
  // `createRequire`; this guards requires inside already-resolvable CJS packages.
  const ModuleAny = Module as unknown as {
    _load: (request: string, parent: unknown, isMain: boolean) => unknown;
  };
  const originalLoad = ModuleAny._load;
  function patchedLoad(this: unknown, request: string, parent: unknown, isMain: boolean): unknown {
    // Curated `os`: an extension whose package.json lacks "type":"module" is transpiled to CJS, so its
    // `import os from "os"` becomes require("os") and arrives HERE (not the ESM deny-loader). Return the
    // same read-only shim instead of denying, so the redirect covers CJS-output extensions too.
    if (request === "os" || request === "node:os") return CURATED_OS_CJS;
    if (isDeniedBuiltin(request)) {
      throw new Error(`[invoke:sandbox] require("${request}") is denied (PLAN.md §4.4)`);
    }
    return originalLoad.call(this, request, parent, isMain);
  }
  // Pin it non-writable so the extension can't restore the original loader (defense in depth:
  // it has no Module reference today, but make the property un-revertible regardless).
  Object.defineProperty(ModuleAny, "_load", { value: patchedLoad, writable: false, configurable: false });

  // (1) ESM import(): a resolve hook that throws for denied builtins, for this and every
  // subsequent dynamic/static import in the process (i.e. the whole extension module graph).
  register("./deny-loader.mjs", import.meta.url);
}
