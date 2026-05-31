/**
 * Tech Radar — "give me the best things to read about X, and the latest news."
 *
 * Fans a single query across keyless, engineering-grade sources and merges them: Hacker News
 * (relevance + by-date), Stack Overflow, Dev.to, and GitHub. A "Latest" section surfaces the freshest
 * items (news); per-source sections surface the best reading. Written against @raycast/api (compat
 * proof). Sources are public + keyless; a slow/blocked one degrades gracefully (Promise.allSettled).
 *
 * Note: the query is debounced in JS — Invoke doesn't yet honor the List `throttle` prop natively,
 * so without this every keystroke would fire fetches and trip rate limits (GitHub 10/min, etc.).
 */
import { List, ActionPanel, Action, getPreferenceValues } from "@raycast/api";
import { usePromise } from "@raycast/utils";
import { useEffect, useState } from "react";

interface Preferences {
  defaultTopic?: string;
}

interface Item {
  id: string;
  title: string;
  url: string;
  source: string;
  meta?: string;
  subtitle?: string;
  date?: number; // unix seconds
}

const UA: Record<string, string> = { "User-Agent": "Invoke-TechRadar/0.1 (+https://github.com/kapildave6/invoke-v2)" };

async function getJSON(url: string, headers?: Record<string, string>): Promise<any> {
  const res = await fetch(url, headers ? { headers } : undefined);
  if (!res.ok) throw new Error(`${res.status} ${res.statusText}`);
  return res.json();
}

/** Decode the handful of HTML entities Stack Overflow puts in titles. */
function decode(s: string): string {
  return s
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#(?:39|x27);/g, "'")
    .replace(/&#x2F;/g, "/");
}

/** Dev.to filters by single-word tag — derive one from the topic ("kafka partitioning" -> "kafka"). */
function tagFrom(q: string): string {
  return (q.toLowerCase().match(/[a-z0-9]+/g) ?? [])[0] ?? "";
}

async function hackerNews(q: string, byDate = false): Promise<Item[]> {
  const ep = byDate ? "search_by_date" : "search";
  const d = await getJSON(`https://hn.algolia.com/api/v1/${ep}?tags=story&hitsPerPage=8&query=${encodeURIComponent(q)}`);
  return (d.hits ?? [])
    .filter((h: any) => h.title)
    .map((h: any) => ({
      id: `hn-${h.objectID}`,
      title: h.title,
      url: h.url || `https://news.ycombinator.com/item?id=${h.objectID}`,
      source: "Hacker News",
      meta: `▲${h.points ?? 0} · ${h.num_comments ?? 0}c`,
      subtitle: `by ${h.author}`,
      date: h.created_at_i,
    }));
}

async function stackOverflow(q: string): Promise<Item[]> {
  const d = await getJSON(
    `https://api.stackexchange.com/2.3/search/advanced?order=desc&sort=relevance&q=${encodeURIComponent(q)}&site=stackoverflow&pagesize=8`,
  );
  return (d.items ?? [])
    .filter((it: any) => it.title)
    .slice(0, 6)
    .map((it: any) => ({
      id: `so-${it.question_id}`,
      title: decode(it.title),
      url: it.link,
      source: "Stack Overflow",
      meta: `▲${it.score ?? 0} · ${it.answer_count ?? 0}a${it.is_answered ? " ✓" : ""}`,
      subtitle: (it.tags ?? []).slice(0, 3).join(", "),
      date: it.creation_date,
    }));
}

async function devto(tag: string): Promise<Item[]> {
  if (!tag) return [];
  const d = await getJSON(`https://dev.to/api/articles?per_page=8&tag=${encodeURIComponent(tag)}`);
  return (Array.isArray(d) ? d : [])
    .filter((a: any) => a.title)
    .slice(0, 6)
    .map((a: any) => ({
      id: `devto-${a.id}`,
      title: a.title,
      url: a.url,
      source: "Dev.to",
      meta: `♥${a.public_reactions_count ?? 0}`,
      subtitle: a.user?.name ? `by ${a.user.name}` : undefined,
      date: a.published_timestamp ? Math.floor(new Date(a.published_timestamp).getTime() / 1000) : undefined,
    }));
}

async function github(q: string): Promise<Item[]> {
  const d = await getJSON(`https://api.github.com/search/repositories?q=${encodeURIComponent(q)}&sort=stars&order=desc&per_page=6`, UA);
  return (d.items ?? []).map((r: any) => ({
    id: `gh-${r.id}`,
    title: r.full_name,
    url: r.html_url,
    source: "GitHub",
    meta: `★${r.stargazers_count ?? 0}`,
    subtitle: r.description ?? undefined,
  }));
}

function settled(r: PromiseSettledResult<Item[]>): Item[] {
  return r.status === "fulfilled" ? r.value : [];
}

/** Compact relative age, e.g. "3m", "5h", "2d". */
function rel(unix?: number): string {
  if (!unix) return "";
  const s = Math.max(0, Math.floor(Date.now() / 1000) - unix);
  if (s < 60) return `${s}s`;
  const m = Math.floor(s / 60);
  if (m < 60) return `${m}m`;
  const h = Math.floor(m / 60);
  if (h < 24) return `${h}h`;
  const d = Math.floor(h / 24);
  if (d < 30) return `${d}d`;
  const mo = Math.floor(d / 30);
  return mo < 12 ? `${mo}mo` : `${Math.floor(mo / 12)}y`;
}

function useDebounced<T>(value: T, ms: number): T {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const id = setTimeout(() => setDebounced(value), ms);
    return () => clearTimeout(id);
  }, [value, ms]);
  return debounced;
}

interface Groups {
  latest: Item[];
  hn: Item[];
  stack: Item[];
  devto: Item[];
  github: Item[];
}

function section(title: string, items: Item[], showDate: boolean) {
  if (items.length === 0) return null;
  return (
    <List.Section key={title} title={title} subtitle={`${items.length}`}>
      {items.map((it) => (
        <List.Item
          key={it.id}
          title={it.title}
          subtitle={it.subtitle}
          accessories={[
            ...(showDate && it.date ? [{ text: rel(it.date) }] : []),
            ...(it.meta ? [{ text: it.meta }] : []),
            { tag: it.source },
          ]}
          actions={
            <ActionPanel>
              <Action.OpenInBrowser url={it.url} />
              <Action.CopyToClipboard title="Copy Link" content={it.url} />
              <Action.CopyToClipboard title="Copy as Markdown" content={`[${it.title}](${it.url})`} />
            </ActionPanel>
          }
        />
      ))}
    </List.Section>
  );
}

export default function Command() {
  const prefs = getPreferenceValues<Preferences>();
  const [query, setQuery] = useState(prefs.defaultTopic ?? "");
  const q = useDebounced(query.trim(), 400);

  const { data, isLoading } = usePromise(async (): Promise<Groups | null> => {
    if (!q) return null;
    const [hn, hnLatest, stack, dev, gh] = await Promise.allSettled([
      hackerNews(q),
      hackerNews(q, true),
      stackOverflow(q),
      devto(tagFrom(q)),
      github(q),
    ]);
    const latest = [...settled(hnLatest), ...settled(stack), ...settled(dev)]
      .filter((i) => i.date)
      .sort((a, b) => (b.date ?? 0) - (a.date ?? 0))
      .slice(0, 6);
    return { latest, hn: settled(hn), stack: settled(stack), devto: settled(dev), github: settled(gh) };
  }, [q]);

  const busy = isLoading || query.trim() !== q;

  return (
    <List
      searchBarPlaceholder="Search a topic — e.g. kafka partitioning, rust async, vector databases…"
      onSearchTextChange={setQuery}
      isLoading={busy}
      throttle
    >
      {!q ? (
        <List.Section title="Type a topic to read about — searches Hacker News · Stack Overflow · Dev.to · GitHub" />
      ) : (
        [
          section("📰 Latest", data?.latest ?? [], true),
          section("💬 Hacker News", data?.hn ?? [], true),
          section("❓ Stack Overflow", data?.stack ?? [], true),
          section(`📝 Dev.to (#${tagFrom(q)})`, data?.devto ?? [], true),
          section("🛠 GitHub Repos", data?.github ?? [], false),
        ]
      )}
    </List>
  );
}
