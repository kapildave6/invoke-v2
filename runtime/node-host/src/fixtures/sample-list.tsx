/**
 * Sample `view` command. Note the import is from "@invoke/api" — an unmodified
 * Raycast extension would import from "@raycast/api" and resolve to the compat
 * shim instead (PLAN.md §5.0). The component code is identical either way.
 */
import { List, ActionPanel, Action } from "@invoke/api";
import { useState } from "react";

const FRUITS = ["Apple", "Apricot", "Banana", "Cherry", "Date", "Fig", "Grape", "Mango"];

export default function Command() {
  const [query, setQuery] = useState("");
  const [pinned, setPinned] = useState<string[]>([]);

  const matches = FRUITS.filter((f) => f.toLowerCase().includes(query.toLowerCase()));

  return (
    <List searchBarPlaceholder="Search fruit…" onSearchTextChange={setQuery} isLoading={false}>
      {pinned.length > 0 && (
        <List.Section title="Pinned">
          {pinned.map((f) => (
            <List.Item key={`pin-${f}`} title={f} accessories={[{ tag: "pinned" }]} />
          ))}
        </List.Section>
      )}
      <List.Section title={`Fruit (${matches.length})`}>
        {matches.map((f) => (
          <List.Item
            key={f}
            title={f}
            subtitle={`${f.length} letters`}
            actions={
              <ActionPanel>
                <Action title="Pin" onAction={() => setPinned((p) => (p.includes(f) ? p : [...p, f]))} />
                <Action.CopyToClipboard content={f} />
              </ActionPanel>
            }
          />
        ))}
      </List.Section>
    </List>
  );
}
