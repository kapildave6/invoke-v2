/**
 * BrowserExtension tests. Pure logic + a mocked host bridge; no runtime needed:
 *   npx tsx packages/api/src/browser-extension.test.ts   (wired as `npm run test:browser`)
 * Exits non-zero on any failure.
 */
import { BrowserExtension, htmlToMarkdown } from "./index.ts";

let pass = 0;
let fail = 0;
function check(name: string, cond: boolean): void {
  if (cond) pass++;
  else { fail++; console.error(`FAIL ${name}`); }
}

// htmlToMarkdown — pure
const md = htmlToMarkdown("<h1>Title</h1><p>Hello <b>world</b> <a href='https://x.com'>link</a></p>");
check("md heading", md.includes("# Title"));
check("md bold", md.includes("**world**"));
check("md link", md.includes("[link](https://x.com)"));
check("md strips unknown tags", htmlToMarkdown("<span>plain</span>").includes("plain"));

// Mock the host RPC bridge (globalThis.__invokeHostRpc__), recording calls.
const BRIDGE_KEY = "__invokeHostRpc__";
const calls: Array<{ method: string; params: Record<string, unknown> }> = [];
(globalThis as Record<string, unknown>)[BRIDGE_KEY] = async (method: string, params: Record<string, unknown>) => {
  calls.push({ method, params });
  if (method === "browser.getTabs") return [{ id: "1:1", url: "https://x.com", title: "X", active: true }];
  if (method === "browser.getContent") return "<h1>Hi</h1>";
  return null;
};

async function main(): Promise<void> {
  const tabs = await BrowserExtension.getTabs();
  check("getTabs url", tabs[0]?.url === "https://x.com");
  check("getTabs derives favicon", (tabs[0]?.favicon ?? "").includes("x.com"));

  const out = await BrowserExtension.getContent({ format: "markdown" });
  const last = calls[calls.length - 1];
  check("getContent markdown requests html", last.method === "browser.getContent" && last.params.format === "html");
  check("getContent markdown converts", out.includes("# Hi"));

  await BrowserExtension.getContent({ format: "text" });
  check("getContent text passthrough", calls[calls.length - 1].params.format === "text");

  console.log(`${pass} passed, ${fail} failed`);
  if (fail > 0) process.exit(1);
}
void main();
