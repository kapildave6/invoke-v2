import { List, Color, Icon, ActionPanel, Action, showToast, Toast } from "@raycast/api";
import { useState, useEffect } from "react";

export default function Command() {
  const [isLoading, setIsLoading] = useState(true);
  useEffect(() => {
    const t = setTimeout(() => setIsLoading(false), 4000); // bar shows ~4s, then clears
    return () => clearTimeout(t);
  }, []);
  const now = Date.now();
  return (
    <List isLoading={isLoading}>
      <List.Item
        title="Colored tag"
        accessories={[{ tag: { value: "Error", color: Color.Red } }]}
        actions={
          <ActionPanel>
            <ActionPanel.Section title="Primary">
              <Action title="Open" icon={Icon.ArrowRight} onAction={() => showToast({ style: Toast.Style.Success, title: "Open" })} />
              <Action title="Copy URL" icon={Icon.Clipboard} onAction={() => showToast({ style: Toast.Style.Success, title: "Copied" })} />
            </ActionPanel.Section>
            <ActionPanel.Section title="Danger">
              <Action title="Delete" icon={Icon.Trash} onAction={() => showToast({ style: Toast.Style.Failure, title: "Deleted" })} />
            </ActionPanel.Section>
            <ActionPanel.Submenu title="Open In" icon={Icon.Globe}>
              <Action title="Safari" onAction={() => showToast({ title: "Safari" })} />
              <Action title="Chrome" onAction={() => showToast({ title: "Chrome" })} />
            </ActionPanel.Submenu>
          </ActionPanel>
        }
      />
      <List.Item title="Plain tag" accessories={[{ tag: "v2.1.0" }]} />
      <List.Item title="Numeric tag" accessories={[{ tag: 42 }]} />
      <List.Item title="Colored text" accessories={[{ text: { value: "Pro", color: Color.Green } }]} />
      <List.Item title="Icon only" accessories={[{ icon: Icon.Star }]} />
      <List.Item title="Icon + text combined" accessories={[{ icon: Icon.Person, text: "42" }]} />
      <List.Item title="Tinted icon" accessories={[{ icon: { source: Icon.Circle, tintColor: Color.Orange } }]} />
      <List.Item title="Relative date" accessories={[{ date: new Date(now - 3 * 86_400_000) }]} />
      <List.Item title="Colored date" accessories={[{ date: { value: new Date(now + 2 * 3_600_000), color: Color.Blue } }]} />
      <List.Item title="Tooltip + hex + multi" accessories={[{ icon: Icon.Circle, tooltip: "status: ok" }, { tag: { value: "Live", color: "#22C55E" } }]} />
    </List>
  );
}
