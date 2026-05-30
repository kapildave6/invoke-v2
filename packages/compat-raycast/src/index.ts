/**
 * @raycast/api — COMPAT SHIM (PLAN.md §5.0 + §10).
 *
 * This package is named `@raycast/api` only so that an unmodified Raycast
 * extension's `import { List } from "@raycast/api"` resolves here. Everything it
 * exports is Invoke's OWN clean-room implementation (re-exported from @invoke/api).
 * It contains zero Raycast source. The `invoke import` codemod handles manifest
 * deltas; this shim handles the import surface.
 */
export * from "@invoke/api";
