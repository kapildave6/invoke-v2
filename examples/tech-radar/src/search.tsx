/**
 * Tech Radar — "give me something to read about X, and the latest news."
 *
 * Fans out a single query across several keyless, engineering-grade sources and merges the results:
 * Hacker News, Lobsters, Dev.to, Reddit and GitHub. A "Latest" section surfaces the freshest items
 * (news); per-source sections surface the best reading. Written against @raycast/api so it doubles as
 * a compat-shim proof. All sources are public + keyless; failures degrade gracefully (Promise.allSettled).
 */
import { List, ActionPanel, Action, getPreferenceValues } from "@raycast/api";
import { usePromise } from "@raycast/utils";
import { useState } from "react";

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

async function lobsters(q: string): Promise<Item[]> {
  const d = await getJSON(`https://lobste.rs/search.json?q=${encodeURIComponent(q)}&what=stories&order=relevance`);
  const stories: any[] = Array.isArray(d) ? d : (d.stories ?? []);
  return stories.slice(0, 6).map((s: any) => ({
    id: `lob-${s.short_id ?? s.url}`,
    title: s.title,
    url: s.url || s.comments_url,
    source: "Lobsters",
    meta: `▲${s.score ?? 0}`,
    subtitle: (s.tags ?? []).join(", "),
    date: s.created_at ? Math.floor(new Date(s.created_at).getTime() / 1000) : undefined,
  }));
}

async function devto(q: string): Promise<Item[]> {
  const d = await getJSON(`https://dev.to/search/feed_content?per_page=8&class_name=Article&search_fields=${encodeURIComponent(q)}`);
  return (d.result ?? [])
    .filter((a: any) => a.title && a.path)
    .slice(0, 6)
    .map((a: any) => ({
      id: `devto-${a.id}`,
      title: a.title,
      url: `https://dev.to${a.path}`,
      source: "Dev.to",
      meta: `♥${a.public_reactions_count ?? 0}`,
      subtitle: a.user?.name ? `by ${a.user.name}` : undefined,
    }));
}

async function reddit(q: string): Promise<Item[]> {
  const d = await getJSON(`https://www.reddit.com/search.json?q=${encodeURIComponent(q)}&limit=8&sort=relevance&t=year`, UA);
  return (d.data?.children ?? [])
    .map((c: any) => c.data)
    .filter((p: any) => p && p.title)
    .slice(0, 6)
    .map((p: any) => ({
      id: `rd-${p.id}`,
      title: p.title,
      url: p.url_overridden_by_dest || `https://www.reddit.com${p.permalink}`,
      source: `r/${p.subreddit}`,
      meta: `▲${p.score ?? 0}`,
      subtitle: `r/${p.subreddit}`,
      date: p.created_utc,
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

interface Groups {
  latest: Item[];
  hn: Item[];
  lobsters: Item[];
  devto: Item[];
  reddit: Item[];
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
  const q = query.trim();

  const { data, isLoading } = usePromise(async (): Promise<Groups | null> => {
    if (!q) return null;
    const [hn, hnLatest, lob, dev, rd, gh] = await Promise.allSettled([
      hackerNews(q),
      hackerNews(q, true),
      lobsters(q),
      devto(q),
      reddit(q),
      github(q),
    ]);
    const latest = [...settled(hnLatest), ...settled(lob), ...settled(rd)]
      .filter((i) => i.date)
      .sort((a, b) => (b.date ?? 0) - (a.date ?? 0))
      .slice(0, 6);
    return { latest, hn: settled(hn), lobsters: settled(lob), devto: settled(dev), reddit: settled(rd), github: settled(gh) };
  }, [q]);

  return (
    <List searchBarPlaceholder="Search a topic — e.g. kafka partitioning, rust async, vector databases…" onSearchTextChange={setQuery} isLoading={isLoading} throttle>
      {!q ? (
        <List.Section title="Type a topic to read about — searches HN · Lobsters · Dev.to · Reddit · GitHub" />
      ) : (
        [
          section("📰 Latest", data?.latest ?? [], true),
          section("💬 Hacker News", data?.hn ?? [], true),
          section("🦞 Lobsters", data?.lobsters ?? [], true),
          section("📝 Dev.to Articles", data?.devto ?? [], false),
          section("👽 Reddit", data?.reddit ?? [], true),
          section("🛠 GitHub Repos", data?.github ?? [], false),
        ]
      )}
    </List>
  );
}
