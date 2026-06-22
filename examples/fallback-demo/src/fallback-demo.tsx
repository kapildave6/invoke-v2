import { Detail, type LaunchProps } from "@raycast/api";
export default function FallbackDemo(props: LaunchProps) {
  const t = props.fallbackText;
  return <Detail markdown={`# Fallback Demo\n\nfallbackText: \`${t ?? "(none)"}\``} />;
}
