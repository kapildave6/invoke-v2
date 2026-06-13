# Raycast extension compatibility checker

A one-shot, deterministic checker that tells you which cloned Raycast extensions
will run on Invoke v2, which run with limitations, and which won't — plus what
it would take to support the rest.

## Quick check (the shortcut)

```sh
# Sandboxed (default, strict — Node built-ins denied):
node tools/compat-check/check.mjs /path/to/extensions --out tools/compat-check/report-sandboxed

# Trusted (unsandboxed — extensions get full Node access):
node tools/compat-check/check.mjs /path/to/extensions --trusted --out tools/compat-check/report-trusted

# What-if roadmap projection (how many extensions each milestone unblocks):
node tools/compat-check/project.mjs tools/compat-check/report-sandboxed/results.json
```

No build step, no deps — plain Node ESM. It recurses the folder, finds every
Raycast manifest (a `package.json` with `commands[]` or a `@raycast/api`
dependency), and classifies each extension.

## What it inspects

Per extension it statically extracts:
- Named/namespace imports from `@raycast/api` and `@raycast/utils`
- Command `mode`s, `arguments[]`, `interval`, `tools[]`, `ai` from the manifest
- Node built-in usage (`fs`, `child_process`, …) vs the sandbox safe-list

…and checks them against the API surface Invoke v2 actually implements
(`packages/api`, `packages/utils`, `runtime/node-host`).

## Classification

- **SUPPORTED** — uses only implemented APIs; runs unmodified.
- **DEGRADED** — runs, but some calls are no-ops/stubbed (e.g. `useNavigation`
  push, `confirmAlert`, `Cache` writes, `useExec` in sandbox).
- **UNSUPPORTED** — imports an unimplemented export (module load fails), uses a
  throwing stub (`AI`, `OAuth`, selection APIs), declares an unsupported command
  `mode`, or (sandboxed) uses a denied Node built-in.

## Outputs (per `--out` dir)

- `report.md` — summary + top gaps + per-extension reasons
- `extensions.csv` — one row per extension (sortable/filterable)
- `results.json` — machine-readable, used by `project.mjs` and the remediation docs

## How to make more extensions supported

See `remediation/` — one doc per gap category — and `REMEDIATION.md` for the
prioritized roadmap with projected unblock counts.
