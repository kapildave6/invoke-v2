import { Detail, environment, Form, Keyboard, type LaunchProps, type Navigation, type PreferenceValues } from "@raycast/api";

// type-only guards (prove Form.Values / Keyboard.KeyModifier resolve as types):
const _fv: Form.Values = {};
const _km: Keyboard.KeyModifier = "cmd";
void _fv; void _km;

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
