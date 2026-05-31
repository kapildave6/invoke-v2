import { Detail, ActionPanel, Action } from "@raycast/api";

const md = `# Invoke Detail

This is a **Detail** surface rendered natively by Invoke.

- Markdown headings, *italic*, **bold**, and \`inline code\`
- A metadata sidebar on the right
- Actions in the ⌘K panel (and ↵)

> Built on the same @raycast/api the rest of the ecosystem uses.

[Open the repo](https://github.com/kapildave6/invoke-v2)`;

export default function Command() {
  return (
    <Detail
      markdown={md}
      metadata={
        <Detail.Metadata>
          <Detail.Metadata.Label title="Status" text="Active" />
          <Detail.Metadata.Label title="Version" text="0.1 (dev)" />
          <Detail.Metadata.Label title="Surface" text="Detail" />
        </Detail.Metadata>
      }
      actions={
        <ActionPanel>
          <Action.OpenInBrowser url="https://github.com/kapildave6/invoke-v2" />
          <Action.CopyToClipboard title="Copy Repo URL" content="https://github.com/kapildave6/invoke-v2" />
        </ActionPanel>
      }
    />
  );
}
