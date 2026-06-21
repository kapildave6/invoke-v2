import { List } from "@raycast/api";
import { useState } from "react";

const ALL = ["Apple", "Banana", "Cherry", "Date", "Elderberry"];

export default function ControlledSearch() {
  const [text, setText] = useState("");
  const [cat, setCat] = useState("all");
  // Controlled: upper-case the query back into the bar (proves controlled reflection).
  const onChange = (q: string) => setText(q.toUpperCase());
  const items = ALL.filter((f) => f.toUpperCase().includes(text)).filter((f) => cat === "all" || (f[0].toLowerCase() <= "c") === (cat === "early"));
  return (
    <List
      searchText={text}
      onSearchTextChange={onChange}
      throttle
      filtering={false}
      searchBarPlaceholder="Type — it reflects UPPER-CASED"
      searchBarAccessory={
        <List.Dropdown tooltip="Category" storeValue defaultValue="all" onChange={setCat}>
          <List.Dropdown.Item title="All" value="all" />
          <List.Dropdown.Item title="Early (A–C)" value="early" />
          <List.Dropdown.Item title="Late (D+)" value="late" />
        </List.Dropdown>
      }
    >
      {items.map((f) => (
        <List.Item key={f} title={f} />
      ))}
    </List>
  );
}
