import { List, ActionPanel, Action, Detail } from "@raycast/api";

const TOPICS = [
  { id: "kafka", title: "Kafka Partitioning", body: "# Kafka Partitioning\n\nPartitions are the unit of **parallelism** in Kafka.\n\n- Order is guaranteed *within* a partition\n- Key choice drives partition assignment\n- More partitions = more consumer parallelism" },
  { id: "raft", title: "The Raft Protocol", body: "# Raft\n\nA consensus algorithm that's easier to understand than Paxos.\n\n- Leader election\n- Log replication\n- Safety via term numbers" },
  { id: "crdt", title: "CRDTs", body: "# CRDTs\n\n**Conflict-free Replicated Data Types** converge without coordination.\n\n- State-based (CvRDT) vs operation-based (CmRDT)\n- Used in collaborative editing & offline-first apps" },
];

export default function Command() {
  return (
    <List searchBarPlaceholder="Pick a topic to read…">
      <List.Section title="Topics">
        {TOPICS.map((t) => (
          <List.Item
            key={t.id}
            title={t.title}
            actions={
              <ActionPanel>
                <Action.Push
                  title="Read"
                  target={
                    <Detail
                      markdown={t.body}
                      actions={
                        <ActionPanel>
                          <Action.OpenInBrowser url={`https://hn.algolia.com/?q=${encodeURIComponent(t.title)}`} />
                        </ActionPanel>
                      }
                    />
                  }
                />
              </ActionPanel>
            }
          />
        ))}
      </List.Section>
    </List>
  );
}
