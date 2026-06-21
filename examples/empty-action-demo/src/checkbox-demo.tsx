import { Form } from "@raycast/api";
import { useState } from "react";

export default function CheckboxDemo() {
  const [on, setOn] = useState(false);
  return (
    <Form>
      <Form.Checkbox id="feature" label="Enable feature" value={on} onChange={setOn} />
      <Form.Description
        title="Received value"
        text={on ? "boolean true ✓" : "boolean false ✓ (not a truthy string)"}
      />
    </Form>
  );
}
