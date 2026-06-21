import { List, ActionPanel, Action, Icon, Toast, showToast } from "@raycast/api";
import { useState } from "react";

export default function ListDemo() {
  const [query, setQuery] = useState("");
  const all = ["Alpha", "Beta", "Gamma"];
  const items = all.filter((s) => s.toLowerCase().includes(query.toLowerCase()));
  return (
    <List onSearchTextChange={setQuery} searchBarPlaceholder="Filter (try 'zzz' for the empty state)">
      {items.length === 0 ? (
        <List.EmptyView
          icon={Icon.MagnifyingGlass}
          title="No Matches"
          description="Try a different search term"
          actions={
            <ActionPanel>
              <Action
                title="Reset Search"
                icon={Icon.ArrowCounterClockwise}
                shortcut={{ modifiers: ["cmd"], key: "r" }}
                onAction={() => showToast({ title: "Reset (⌘R from EmptyView)" })}
              />
            </ActionPanel>
          }
        />
      ) : (
        items.map((s) => (
          <List.Item
            key={s}
            title={s}
            actions={
              <ActionPanel>
                <Action title="Show Toast" onAction={() => showToast({ title: `Hello ${s}` })} />
                <Action
                  title="Custom Shortcut"
                  shortcut={{ modifiers: ["cmd", "shift"], key: "k" }}
                  onAction={() => showToast({ title: "⌘⇧K fired!" })}
                />
                <Action
                  title="Delete"
                  style={Action.Style.Destructive}
                  onAction={() => showToast({ style: Toast.Style.Failure, title: `Deleted ${s}` })}
                />
              </ActionPanel>
            }
          />
        ))
      )}
    </List>
  );
}
