/**
 * Compat shim for the `run-applescript` npm package (PLAN.md §4.4 / §5.0).
 *
 * Many Raycast extensions (e.g. YouTube Music) import `runAppleScript` from `run-applescript` instead
 * of `@raycast/utils`. That package shells out to `osascript` via child_process — which the sandbox
 * denies — and v6+ is ESM-only (a CJS-transpiled extension can't even require it). The deny-loader /
 * Module._load patch redirect an extension's `run-applescript` import HERE, where we route the script
 * through the host's gated `runAppleScript` capability over the RPC bridge instead.
 *
 * Mirrors run-applescript's surface: a named `runAppleScript(script)` and a default export.
 */
function hostRunAppleScript(script) {
  const send = globalThis["__invokeHostRpc__"];
  if (typeof send !== "function") {
    return Promise.reject(new Error("run-applescript shim: host bridge not ready"));
  }
  const source = typeof script === "string" ? script : String(script ?? "");
  return send("runAppleScript", { source });
}

export function runAppleScript(script) {
  return hostRunAppleScript(script);
}

export default runAppleScript;
