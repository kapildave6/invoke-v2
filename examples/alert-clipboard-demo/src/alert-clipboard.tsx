import { List, ActionPanel, Action, Icon, Alert, Clipboard, confirmAlert, showToast, useNavigation, Detail } from "@raycast/api";
import { useState } from "react";

function Result({ text }: { text: string }) {
  return <Detail markdown={text} />;
}

export default function Demo() {
  const { push } = useNavigation();
  return (
    <List>
      <List.Item
        title="Confirm Alert (icon + remember)"
        actions={
          <ActionPanel>
            <Action
              title="Delete…"
              style={Action.Style.Destructive}
              onAction={async () => {
                const ok = await confirmAlert({
                  icon: Icon.Trash,
                  title: "Delete item?",
                  message: "This cannot be undone.",
                  primaryAction: { title: "Delete", style: Alert.ActionStyle.Destructive },
                  rememberUserChoice: true,
                });
                await showToast({ title: ok ? "Confirmed" : "Cancelled" });
              }}
            />
          </ActionPanel>
        }
      />
      <List.Item
        title="Clipboard.read (full)"
        actions={
          <ActionPanel>
            <Action
              title="Read Clipboard"
              onAction={async () => {
                await Clipboard.copy("placeholder text");
                const r = await Clipboard.read();
                push(<Result text={`# Clipboard\n\ntext: \`${r.text}\`\n\nhtml: \`${r.html ?? "—"}\`\n\nfile: \`${r.file ?? "—"}\``} />);
              }}
            />
          </ActionPanel>
        }
      />
      <List.Item
        title="Clipboard.clear"
        actions={
          <ActionPanel>
            <Action title="Clear Clipboard" onAction={async () => { await Clipboard.clear(); await showToast({ title: "Clipboard cleared" }); }} />
          </ActionPanel>
        }
      />
    </List>
  );
}
