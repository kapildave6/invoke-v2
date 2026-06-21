import { List, Icon, Color, Image } from "@raycast/api";

export default function Visual() {
  return (
    <List>
      <List.Item title="Bug (was generic)" icon={Icon.Bug} />
      <List.Item title="Rocket" icon={Icon.Rocket} />
      <List.Item title="Bell" icon={Icon.Bell} />
      <List.Item title="House" icon={Icon.House} />
      <List.Item title="Dynamic color tag" icon={{ source: Icon.Circle, tintColor: Color.Dynamic({ light: "#1111ee", dark: "#88aaff" }) }} accessories={[{ tag: { value: "dynamic", color: Color.Dynamic({ light: "#1111ee", dark: "#88aaff" }) } }]} />
      <List.Item title="Circle-masked avatar" icon={{ source: "https://raycast.com/uploads/avatar.png", mask: Image.Mask.Circle }} />
    </List>
  );
}
