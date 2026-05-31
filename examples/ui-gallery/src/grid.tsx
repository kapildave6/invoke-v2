import { Grid, ActionPanel, Action, Icon } from "@raycast/api";

const ITEMS = [
  { id: "star", title: "Star", content: Icon.Star },
  { id: "globe", title: "Globe", content: Icon.Globe },
  { id: "clipboard", title: "Clipboard", content: Icon.Clipboard },
  { id: "calendar", title: "Calendar", content: Icon.Calendar },
  { id: "window", title: "Window", content: Icon.Window },
  { id: "search", title: "Search", content: Icon.MagnifyingGlass },
];

export default function Command() {
  return (
    <Grid columns={4} searchBarPlaceholder="Filter icons…">
      <Grid.Section title="Icons">
        {ITEMS.map((it) => (
          <Grid.Item
            key={it.id}
            title={it.title}
            content={it.content}
            actions={
              <ActionPanel>
                <Action.CopyToClipboard title="Copy Name" content={it.title} />
              </ActionPanel>
            }
          />
        ))}
      </Grid.Section>
    </Grid>
  );
}
