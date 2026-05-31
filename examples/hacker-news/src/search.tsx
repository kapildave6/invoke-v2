/**
 * Search Hacker News — a realistic third-party-shaped extension.
 *
 * Note every import is from "@raycast/api" / "@raycast/utils": this is exactly how an UNMODIFIED
 * Raycast extension is written, and it runs in Invoke purely through the compat shims
 * (packages/compat-raycast*). Uses the keyless public HN Algolia API — no auth, no secrets.
 */
import { List, ActionPanel, Action, getPreferenceValues, showToast, Toast, LocalStorage } from "@raycast/api";
import { useFetch } from "@raycast/utils";
import { useEffect, useState } from "react";

interface Preferences {
  defaultQuery?: string;
}

interface Hit {
  objectID: string;
  title: string | null;
  url: string | null;
  author: string;
  points: number;
  num_comments: number;
}

interface SearchResponse {
  hits: Hit[];
}

const LAST_QUERY_KEY = "lastQuery";

export default function Command() {
  const prefs = getPreferenceValues<Preferences>();
  const [query, setQuery] = useState(prefs.defaultQuery ?? "");

  // Remember the last query across launches (LocalStorage round-trips through the host).
  useEffect(() => {
    if (query) void LocalStorage.setItem(LAST_QUERY_KEY, query);
  }, [query]);

  const endpoint = `https://hn.algolia.com/api/v1/search?tags=story&hitsPerPage=20&query=${encodeURIComponent(query)}`;
  const { data, isLoading, error } = useFetch<SearchResponse>(endpoint);

  useEffect(() => {
    if (error) void showToast({ style: Toast.Style.Failure, title: "Couldn't reach Hacker News", message: error.message });
  }, [error]);

  const hits = data?.hits ?? [];

  return (
    <List searchBarPlaceholder="Search Hacker News…" onSearchTextChange={setQuery} isLoading={isLoading} throttle>
      <List.Section title={query ? `Results for "${query}"` : "Front Page"} subtitle={`${hits.length}`}>
        {hits.map((hit) => {
          const hnUrl = `https://news.ycombinator.com/item?id=${hit.objectID}`;
          return (
            <List.Item
              key={hit.objectID}
              title={hit.title ?? "(untitled)"}
              subtitle={hit.author}
              accessories={[{ text: `▲ ${hit.points}` }, { tag: `${hit.num_comments} comments` }]}
              actions={
                <ActionPanel>
                  {hit.url ? <Action.OpenInBrowser url={hit.url} /> : null}
                  <Action.OpenInBrowser title="Open on Hacker News" url={hnUrl} />
                  {hit.url ? <Action.CopyToClipboard title="Copy Link" content={hit.url} /> : null}
                </ActionPanel>
              }
            />
          );
        })}
      </List.Section>
    </List>
  );
}
