#!/usr/bin/env node
// What-if projection: given the compat scan, recompute how many extensions
// become *runnable* (no remaining import-breaking blocker) after each
// remediation milestone. Accounts for extensions blocked by multiple gaps,
// so milestones don't double-count.
//
// Usage: node tools/compat-check/project.mjs [results.json]

import fs from "node:fs";
import path from "node:path";

const file = process.argv[2] || path.resolve("tools/compat-check/report-sandboxed/results.json");
const { results } = JSON.parse(fs.readFileSync(file, "utf8"));

// Map an issue string -> a capability tag.
function tag(s) {
  if (/Node built-ins|useExec|runPowerShellScript/.test(s)) return "sandbox";
  if (/useNavigation/.test(s)) return "navigation";
  if (/confirmAlert/.test(s)) return "confirmAlert";
  if (/\bCache\b/.test(s)) return "cache";
  if (/openExtensionPreferences|openCommandPreferences/.test(s)) return "prefsOpen";
  if (/captureException/.test(s)) return "captureException";
  if (/arguments\[\]/.test(s)) return "arguments";
  if (/interval/.test(s)) return "interval";
  if (/AI tools\[\]|ai` instructions|@raycast\/api:AI\b|^AI:|useAI/.test(s)) return "ai";
  if (/OAuth|withAccessToken|getAccessToken/.test(s)) return "oauth";
  if (/getSelectedText|getApplications|getFrontmostApplication|getDefaultApplication|getSelectedFinderItems|showInFinder|\btrash\b/.test(s)) return "systemapi";
  if (/unsupported command mode/.test(s)) return "modes";
  if (/ToastStyle|OpenInBrowserAction|CopyToClipboardAction|SubmitFormAction|PushAction|OpenAction|PasteAction|ImageMask|getLocalStorageItem|setLocalStorageItem|removeLocalStorageItem|copyTextToClipboard|pasteText|clearSearchBar|@raycast\/api:preferences\b|randomId/.test(s)) return "legacy";
  if (/launchCommand|updateCommandMetadata|createDeeplink|BrowserExtension|@raycast\/api:Navigation|Deeplink/i.test(s)) return "interopStub";
  if (/getFavicon|getAvatarIcon|getProgressIcon|MutatePromise|useLocalStorage|useFrecencySorting|withCache/.test(s)) return "utilsPureJs";
  if (/useStreamJSON/.test(s)) return "utilsStream";
  return "other"; // unresolved by any planned milestone
}

// Milestones, cumulative. Each lists the tags it newly resolves.
const milestones = [
  { name: "M0 baseline", resolves: [] },
  { name: "M1 cheap S-tier (legacy aliases, load-stubs, pure-JS utils, confirmAlert/Cache/captureException/prefsOpen)",
    resolves: ["legacy", "interopStub", "utilsPureJs", "confirmAlert", "cache", "captureException", "prefsOpen"] },
  { name: "M2 + trusted-mode (Node built-ins / useExec)", resolves: ["sandbox"] },
  { name: "M3 + arguments[] + render-on-push navigation + system/selection APIs + AI.ask/useAI",
    resolves: ["arguments", "navigation", "systemapi", "ai"] },
  { name: "M4 + OAuth + AI-extensions(tools[]) + menu-bar + intervals + streaming",
    resolves: ["oauth", "modes", "interval", "utilsStream"] },
];

// Pre-tag every extension's blocking issues. An extension is "runnable" when it
// has no remaining import-breaking issue. blockers + unknown break import/run;
// degraded still runs. We track both runnable and fully-clean.
const tagged = results.map((r) => {
  const hard = [...new Set([...r.blockers, ...r.unknown].map(tag))];
  const soft = [...new Set(r.degraded.map(tag))];
  return { name: r.name, hard, soft, baseStatus: r.status };
});

const resolved = new Set();
const rows = [];
for (const m of milestones) {
  m.resolves.forEach((t) => resolved.add(t));
  let runnable = 0, clean = 0, otherOnly = 0;
  for (const e of tagged) {
    const hardLeft = e.hard.filter((t) => !resolved.has(t));
    const softLeft = e.soft.filter((t) => !resolved.has(t));
    if (hardLeft.length === 0) {
      runnable++;
      if (softLeft.length === 0) clean++;
    }
    if (hardLeft.length && hardLeft.every((t) => t === "other")) otherOnly++;
  }
  rows.push({ milestone: m.name, runnable, clean, otherOnly });
}

const total = results.length;
console.log(`Projection over ${total} extensions (runnable = imports/loads & runs; fully-supported = no degradation):\n`);
console.log("milestone".padEnd(95), "runnable".padStart(9), "supported".padStart(10), "run%".padStart(7));
for (const r of rows) {
  console.log(
    r.milestone.slice(0, 95).padEnd(95),
    String(r.runnable).padStart(9),
    String(r.clean).padStart(10),
    ((r.runnable / total) * 100).toFixed(0).padStart(6) + "%"
  );
}
// How many remain blocked only by "other" (third-party/unmapped) at the end:
console.log(`\nRemaining blocked only by unmapped/third-party causes after M4: ${rows[rows.length - 1].otherOnly}`);

// Tag frequency across all hard blockers (how many extensions each tag blocks).
const freq = new Map();
for (const e of tagged) for (const t of e.hard) freq.set(t, (freq.get(t) || 0) + 1);
console.log(`\nHard-blocker reach by capability tag:`);
[...freq.entries()].sort((a, b) => b[1] - a[1]).forEach(([t, n]) => console.log("  " + String(n).padStart(4), t));
