import { List } from "@raycast/api";

export default function StaticList() {
  return (
    <List filtering={false} searchBarPlaceholder="Typing here filters nothing (filtering=false)">
      <List.Item title="Always Visible 1" />
      <List.Item title="Always Visible 2" />
      <List.Item title="Always Visible 3" />
    </List>
  );
}
