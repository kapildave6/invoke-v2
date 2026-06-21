import { Detail, Form, ActionPanel, Action, showToast, useNavigation } from "@raycast/api";

function Tags() {
  return (
    <Detail
      markdown="# Tags + DatePicker demo"
      metadata={
        <Detail.Metadata>
          <Detail.Metadata.TagList title="Labels">
            {["alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta"].map((t) => (
              <Detail.Metadata.TagList.Item key={t} text={t} onAction={t === "beta" ? () => showToast({ title: `Tag ${t} clicked` }) : undefined} />
            ))}
          </Detail.Metadata.TagList>
        </Detail.Metadata>
      }
    />
  );
}

export default function MetadataForm() {
  const { push } = useNavigation();
  return (
    <Form
      actions={<ActionPanel><Action title="Show Tags" onAction={() => push(<Tags />)} /></ActionPanel>}
    >
      <Form.DatePicker
        id="when"
        title="When"
        type={Form.DatePicker.Type.Date}
        min={new Date(2020, 0, 1)}
        max={new Date(2030, 11, 31)}
        onChange={(d) => showToast({ title: `Date: ${d instanceof Date ? d.toISOString() : "not a Date!"}` })}
      />
    </Form>
  );
}
