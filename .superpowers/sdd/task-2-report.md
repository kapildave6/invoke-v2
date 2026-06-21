# Task 2 Report: Scrub ANTHROPIC_API_KEY from spawned extension child env

## Status: DONE

## What was scrubbed

**File changed:** `apps/macos/Sources/InvokeShell/ExtensionHost.swift`

One line added immediately after `var env = ProcessInfo.processInfo.environment` (line 147), before the first `env["INVOKE_COMMAND"] = ...` assignment:

```swift
// Security: the host's AI key must never be readable by a (possibly unsandboxed) extension.
// AI is reached via the gated ai.ask RPC, which runs in the host — the child never needs the key.
env["ANTHROPIC_API_KEY"] = nil
```

**Keys scrubbed:** `ANTHROPIC_API_KEY` only.

## Other-secret search result

Searched the entire `apps/macos/Sources/` tree for `_API_KEY`, `_TOKEN`, `_SECRET`, `_PASSWORD`, `_APIKEY`, and all non-`INVOKE_`-prefixed `ProcessInfo.processInfo.environment[...]` reads.

Result: **No other host-secret env vars found.** The only non-`INVOKE_`-prefixed key the host reads from its own environment is `ANTHROPIC_API_KEY` (in `AIService.swift` lines 42 and 55). No second API key, token, or secret was found anywhere in the codebase. The denylist stays at exactly one entry.

## Host AI unaffected confirmation

`AIService.swift` (`apps/macos/Sources/InvokeServices/AIService.swift`) reads `ANTHROPIC_API_KEY` via `ProcessInfo.processInfo.environment` in the **host process**. The change sets `env["ANTHROPIC_API_KEY"] = nil` on the **copy** of the environment used to build the `envp` array for `posix_spawn()`. This removes only the key from the child process's inherited environment.

`ProcessInfo.processInfo.environment` in the host is not mutated by this nil assignment — Swift's `ProcessInfo.processInfo.environment` returns an immutable `[String: String]` copy; assigning nil to a key in a local var derived from it does not affect the live host process environment. The `AIService.apiKey()` method continues to read `ANTHROPIC_API_KEY` from the host process's own environment (or the Keychain fallback) unchanged. All `ai.ask` RPC calls remain fully functional.

The extension's own preferences and all other env vars (`INVOKE_*`, `TSX_TSCONFIG_PATH`, `PATH`, etc.) are untouched.

## Build result

```
Build complete! (1.64s)
```

No warnings, no errors. Only `ExtensionHost.swift` recompiled.

## Concerns

None. The change is a single-line nil assignment on a copied dictionary, scoped strictly to the one confirmed host-secret. No extension behaviour is broken; extensions that reach AI do so via the `ai.ask` RPC (host-side, keyed with the host's own env/Keychain). The extension's own preference env vars (`INVOKE_PREFERENCES`) are untouched.
