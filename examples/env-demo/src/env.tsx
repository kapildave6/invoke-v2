import { Detail, environment, type LaunchProps, type Navigation, type PreferenceValues } from "@raycast/api";

export default function Env(_props: LaunchProps) {
  const _n: Navigation | null = null; // type-only use (proves export)
  const _p: PreferenceValues = {};
  const md = [
    `# Environment`,
    `- appearance: \`${environment.appearance}\``,
    `- textSize: \`${environment.textSize}\``,
    `- commandName: \`${environment.commandName}\``,
    `- extensionName: \`${environment.extensionName}\``,
    `- canAccess(AI): \`${String((environment as { canAccess?: (a: unknown) => boolean }).canAccess?.(null))}\``,
  ].join("\n");
  return <Detail markdown={md} />;
}
