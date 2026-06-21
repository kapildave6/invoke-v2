import { MenuBarExtra, showHUD, Clipboard } from "@raycast/api";

export default function Menubar() {
  return (
    <MenuBarExtra icon="⌘" title="Demo">
      <MenuBarExtra.Item title="Reload" shortcut={{ modifiers: ["cmd"], key: "r" }} onAction={() => showHUD("Reloaded")} />
      <MenuBarExtra.Item
        title="Copy ID"
        onAction={() => Clipboard.copy("id-123")}
        alternate={<MenuBarExtra.Item title="Copy ID (raw)" onAction={() => Clipboard.copy("123")} />}
      />
      <MenuBarExtra.Item title="Show event type" onAction={(e) => showHUD(`clicked: ${e.type}`)} />
    </MenuBarExtra>
  );
}
