import { List, ActionPanel, Action, Toast, showToast, Clipboard, type ToastHandle } from "@raycast/api";

export default function ToastActions() {
  return (
    <List>
      <List.Item
        title="Show toast with actions"
        actions={
          <ActionPanel>
            <Action
              title="Upload (fails)"
              onAction={async () => {
                await showToast({
                  style: Toast.Style.Failure,
                  title: "Upload failed",
                  primaryAction: { title: "Retry", onAction: (t: ToastHandle) => { t.hide(); void showToast({ title: "Retrying…" }); } },
                  secondaryAction: { title: "Copy Error", onAction: () => { void Clipboard.copy("error details"); } },
                });
              }}
            />
          </ActionPanel>
        }
      />
    </List>
  );
}
