import { Form, Detail, ActionPanel, Action, Color, Icon, useNavigation } from "@raycast/api";

function Result({ pwLen, date }: { pwLen: number; date: string }) {
  const md = `# Submitted\n\nPassword length: **${pwLen}**\n\nDate: **${date}**`;
  return (
    <Detail
      markdown={md}
      metadata={
        <Detail.Metadata>
          <Detail.Metadata.Label title="Status" text={{ value: "Active", color: Color.Green }} icon={Icon.CheckCircle} />
          <Detail.Metadata.Link title="Docs" target="https://developers.raycast.com" text="developers.raycast.com" />
          <Detail.Metadata.Separator />
          <Detail.Metadata.TagList title="Tags">
            <Detail.Metadata.TagList.Item text="urgent" color={Color.Red} />
            <Detail.Metadata.TagList.Item text="review" color={Color.Blue} />
            <Detail.Metadata.TagList.Item text="ok" color="#22C55E" />
          </Detail.Metadata.TagList>
        </Detail.Metadata>
      }
    />
  );
}

export default function Command() {
  const { push } = useNavigation();
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Submit" onSubmit={(v) => push(<Result pwLen={String(v.password ?? "").length} date={String(v.when ?? "")} />)} />
        </ActionPanel>
      }
    >
      <Form.PasswordField id="password" title="Password" placeholder="secret" />
      <Form.DatePicker id="when" title="When" />
    </Form>
  );
}
