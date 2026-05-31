import { Form, ActionPanel, Action, showToast, Toast } from "@raycast/api";

export default function Command() {
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm
            title="Submit"
            onSubmit={(values) =>
              showToast({ style: Toast.Style.Success, title: "Submitted", message: JSON.stringify(values) })
            }
          />
        </ActionPanel>
      }
    >
      <Form.TextField id="name" title="Name" placeholder="Your name" />
      <Form.TextArea id="bio" title="Bio" placeholder="A sentence about you" />
      <Form.Checkbox id="agree" title="Terms" label="I agree to the terms" />
    </Form>
  );
}
