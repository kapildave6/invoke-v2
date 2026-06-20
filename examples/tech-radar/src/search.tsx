/**
 * Tech Radar — "give me the best things to read about X, and the latest news."
 *
 * Fans a single query across keyless, engineering-grade sources and merges them:
 *   • Hacker News (relevance + by-date)   • Stack Overflow   • Dev.to (by tag)
 *   • GitHub repos                        • arXiv papers     • curated engineering-blog RSS feeds
 * A "Latest" section surfaces the freshest dated items (news); per-source sections surface the best
 * reading. Written against @raycast/api (compat proof). All sources are public + keyless; a
 * slow/blocked one degrades gracefully (Promise.allSettled). The query is debounced in JS because
 * Invoke doesn't yet honor the List `throttle` prop natively. RSS feeds are fetched once and cached,
 * then re-filtered per query, so changing topics doesn't re-download megabytes of feeds.
 */
import { List, ActionPanel, Action, getPreferenceValues } from "@raycast/api";
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

/** fetch with a hard timeout. Sources are merged with Promise.allSettled, which only resolves when
 *  the SLOWEST one settles — so a single dead/slow source (a stalled RSS feed) would otherwise hang
 *  the whole merge for Node's full connect timeout (~10s+), leaving the list blank the entire time.
 *  Aborting at `ms` bounds the worst case and lets the live sources through. */
async function fetchT(url: string, init?: RequestInit, ms = 6000): Promise<Response> {
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), ms);
  try {
    return await fetch(url, { ...init, signal: ctrl.signal });
  } finally {
    clearTimeout(timer);
  }
}

async function getJSON(url: string, headers?: Record<string, string>): Promise<any> {
  const res = await fetchT(url, headers ? { headers } : undefined);
  if (!res.ok) throw new Error(`${res.status} ${res.statusText}`);
  return res.json();
}

async function getText(url: string): Promise<string> {
  const res = await fetchT(url, { headers: UA });
  if (!res.ok) throw new Error(`${res.status} ${res.statusText}`);
  return res.text();
}

/** Decode the handful of HTML/XML entities sources put in titles, and strip stray tags. */
function decode(s: string): string {
  return s
    .replace(/<!\[CDATA\[([\s\S]*?)\]\]>/g, "$1")
    .replace(/<[^>]+>/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#(?:39|x27);/g, "'")
    .replace(/&apos;/g, "'")
    .replace(/\s+/g, " ")
    .trim();
}

/** Dev.to filters by single-word tag — derive one from the topic ("kafka partitioning" -> "kafka"). */
function tagFrom(q: string): string {
  return (q.toLowerCase().match(/[a-z0-9]+/g) ?? [])[0] ?? "";
}

// ---- JSON sources -------------------------------------------------------------------------------

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

// ---- XML sources (arXiv + engineering-blog RSS/Atom) --------------------------------------------

function firstTag(block: string, name: string): string | undefined {
  const m = block.match(new RegExp(`<${name}[^>]*>([\\s\\S]*?)</${name}>`, "i"));
  return m ? m[1] : undefined;
}

function toUnix(dateStr?: string): number | undefined {
  if (!dateStr) return undefined;
  const t = new Date(dateStr.trim()).getTime();
  return Number.isFinite(t) ? Math.floor(t / 1000) : undefined;
}

interface FeedEntry {
  title: string;
  url: string;
  date?: number;
  summary: string;
}

/** Tolerant RSS (<item>) + Atom (<entry>) parser — no DOMParser in the Node child. */
function parseFeed(xml: string): FeedEntry[] {
  const isAtom = /<feed[\s>]/i.test(xml) && !/<rss[\s>]/i.test(xml);
  const blocks = xml.split(isAtom ? /<entry[\s>]/i : /<item[\s>]/i).slice(1);
  const out: FeedEntry[] = [];
  for (const b of blocks) {
    const title = decode(firstTag(b, "title") ?? "");
    let url: string | undefined;
    if (isAtom) {
      const link =
        b.match(/<link[^>]*rel="alternate"[^>]*href="([^"]+)"/i) ||
        b.match(/<link[^>]*href="([^"]+)"[^>]*rel="alternate"/i) ||
        b.match(/<link[^>]*href="([^"]+)"/i);
      url = link?.[1];
    } else {
      url = (firstTag(b, "link") ?? "").trim() || undefined;
    }
    const date = toUnix(firstTag(b, "pubDate") ?? firstTag(b, "published") ?? firstTag(b, "updated") ?? firstTag(b, "dc:date"));
    const summary = decode((firstTag(b, "description") ?? firstTag(b, "summary") ?? "").slice(0, 500));
    if (title && url) out.push({ title, url, date, summary });
  }
  return out;
}

async function arxiv(q: string): Promise<Item[]> {
  const xml = await getText(`https://export.arxiv.org/api/query?search_query=all:${encodeURIComponent(q)}&start=0&max_results=5&sortBy=relevance`);
  const blocks = xml.split(/<entry[\s>]/i).slice(1);
  return blocks
    .map((b) => {
      const id = (firstTag(b, "id") ?? "").trim();
      const author = b.match(/<author>\s*<name>([\s\S]*?)<\/name>/i)?.[1]?.trim();
      return {
        id: `arxiv-${id}`,
        title: decode(firstTag(b, "title") ?? ""),
        url: id,
        source: "arXiv",
        subtitle: author ? `by ${author}` : undefined,
        date: toUnix(firstTag(b, "published")),
      } as Item;
    })
    .filter((it) => it.title && it.url)
    .slice(0, 5);
}

// Curated, keyless engineering-blog feeds (probe-verified). Fetched once + cached, re-filtered per query.
const FEEDS: Array<{ name: string; url: string }> = [
  { name: "InfoQ", url: "https://feed.infoq.com/" },
  { name: "Martin Fowler", url: "https://martinfowler.com/feed.atom" },
  { name: "Cloudflare", url: "https://blog.cloudflare.com/rss/" },
  { name: "Netflix Tech", url: "https://netflixtechblog.com/feed" },
  { name: "AWS Big Data", url: "https://aws.amazon.com/blogs/big-data/feed/" },
];

const feedCache = new Map<string, { text: string; at: number }>();
async function cachedFeed(url: string): Promise<string> {
  const c = feedCache.get(url);
  if (c && Date.now() - c.at < 10 * 60 * 1000) return c.text;
  const text = await getText(url);
  feedCache.set(url, { text, at: Date.now() });
  return text;
}

async function engineeringBlogs(q: string): Promise<Item[]> {
  const words = q.toLowerCase().match(/[a-z0-9]{4,}/g) ?? [];
  if (words.length === 0) return [];
  const perFeed = await Promise.allSettled(
    FEEDS.map(async (f) => {
      const entries = parseFeed(await cachedFeed(f.url));
      return entries
        .filter((e) => {
          const hay = `${e.title} ${e.summary}`.toLowerCase();
          return words.some((w) => hay.includes(w));
        })
        .map((e) => ({ id: `blog-${f.name}-${e.url}`, title: e.title, url: e.url, source: f.name, date: e.date } as Item));
    }),
  );
  return perFeed
    .flatMap((r) => (r.status === "fulfilled" ? r.value : []))
    .sort((a, b) => (b.date ?? 0) - (a.date ?? 0))
    .slice(0, 8);
}

// ---- glue ---------------------------------------------------------------------------------------

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
  blogs: Item[];
  devto: Item[];
  papers: Item[];
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

  // Progressive merge: each source fills its own slice the moment it resolves, so the fast core
  // (HN/SO/GitHub/Dev.to/arXiv — typically <1s) renders immediately and the slower engineering-blog
  // feeds stream in behind it. A dead source simply never fills (its fetch times out) instead of
  // blanking the whole list — the prior single Promise.allSettled gated every result on the slowest.
  const [groups, setGroups] = useState<Partial<Groups>>({});
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!q) {
      setGroups({});
      setLoading(false);
      return;
    }
    let live = true;
    setGroups({});
    setLoading(true);
    const set = (patch: Partial<Groups>) => {
      if (live) setGroups((g) => ({ ...g, ...patch }));
    };
    // safe() swallows a source's failure (→ empty) so one dead/slow source can't break the merge.
    const safe = (p: Promise<Item[]>): Promise<Item[]> => p.then((v) => v, () => [] as Item[]);
    const fill = (key: keyof Groups, p: Promise<Item[]>): Promise<Item[]> =>
      p.then((v) => {
        set({ [key]: v } as Partial<Groups>);
        return v;
      });
    // "📰 Latest" = the freshest dated items across the news-y sources. Recompute it incrementally as
    // each input lands (not via one Promise.all) so the top section also streams in and never waits on
    // the slowest/dead source.
    const latestParts: Record<string, Item[]> = {};
    const addLatest = (name: string, v: Item[]) => {
      latestParts[name] = v;
      set({
        latest: Object.values(latestParts)
          .flat()
          .filter((i) => i.date)
          .sort((a, b) => (b.date ?? 0) - (a.date ?? 0))
          .slice(0, 6),
      });
    };
    const feed = (name: string, p: Promise<Item[]>): Promise<Item[]> =>
      p.then((v) => {
        if (live) addLatest(name, v);
        return v;
      });

    const hn = fill("hn", safe(hackerNews(q)));
    const hnLatest = feed("hnLatest", safe(hackerNews(q, true)));
    const stack = feed("stack", fill("stack", safe(stackOverflow(q))));
    const dev = feed("devto", fill("devto", safe(devto(tagFrom(q)))));
    const gh = fill("github", safe(github(q)));
    const papers = feed("arxiv", fill("papers", safe(arxiv(q))));
    const blogs = feed("blogs", fill("blogs", safe(engineeringBlogs(q))));

    Promise.allSettled([hn, hnLatest, stack, dev, gh, papers, blogs]).finally(() => {
      if (live) setLoading(false);
    });
    return () => {
      live = false;
    };
  }, [q]);

  const busy = loading || query.trim() !== q;

  return (
    <List
      searchBarPlaceholder="Search a topic — e.g. kafka partitioning, rust async, vector databases…"
      onSearchTextChange={setQuery}
      isLoading={busy}
      throttle
    >
      {!q ? (
        <List.Section title="Type a topic to read about — HN · Stack Overflow · engineering blogs · Dev.to · arXiv · GitHub" />
      ) : (
        [
          section("📰 Latest", groups.latest ?? [], true),
          section("💬 Hacker News", groups.hn ?? [], true),
          section("❓ Stack Overflow", groups.stack ?? [], true),
          section("📚 Engineering Blogs", groups.blogs ?? [], true),
          section(`📝 Dev.to (#${tagFrom(q)})`, groups.devto ?? [], true),
          section("📄 arXiv Papers", groups.papers ?? [], true),
          section("🛠 GitHub Repos", groups.github ?? [], false),
        ]
      )}
    </List>
  );
}
