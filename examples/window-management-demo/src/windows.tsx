import { Detail, ActionPanel, Action, WindowManagement } from "@raycast/api";
import { useEffect, useState } from "react";

export default function Command() {
  const [md, setMd] = useState("Reading windows…");
  const refresh = async () => {
    try {
      const active = await WindowManagement.getActiveWindow();
      const all = await WindowManagement.getWindowsOnActiveDesktop();
      const desks = await WindowManagement.getDesktops();
      setMd(
        `# Window Management\n\n` +
          `**Active:** ${active.application?.name ?? "?"} — ${JSON.stringify(active.bounds)}\n\n` +
          `**Windows on desktop:** ${all.length}\n\n` +
          all.slice(0, 8).map((w) => `- ${w.application?.name ?? "?"} (${w.id})`).join("\n") +
          `\n\n**Desktops:** ${desks.map((d) => `${d.id}${d.active ? " (active)" : ""}`).join(", ")}`,
      );
    } catch (e) {
      setMd(`# Window Management\n\nError: ${String(e)}\n\n(Grant Accessibility to Invoke.)`);
    }
  };
  useEffect(() => { void refresh(); }, []);
  const nudge = async () => {
    const w = await WindowManagement.getActiveWindow();
    await WindowManagement.setWindowBounds({ id: w.id, bounds: { position: { x: w.bounds.position.x + 20, y: w.bounds.position.y } } });
    await refresh();
  };
  return <Detail markdown={md} actions={<ActionPanel><Action title="Nudge Active Window +20" onAction={nudge} /><Action title="Refresh" onAction={refresh} /></ActionPanel>} />;
}
