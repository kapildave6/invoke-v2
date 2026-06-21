import { List } from "@raycast/api";
import { usePromise } from "@raycast/utils";

const TOTAL = 120; // 6 pages of 20
export default function Command() {
  const { data, isLoading, pagination } = usePromise(
    () => async ({ page }: { page: number }) => {
      await new Promise((r) => setTimeout(r, 400)); // simulate a fetch
      const start = page * 20;
      const items = Array.from({ length: 20 }, (_, i) => start + i).filter((n) => n < TOTAL);
      return { data: items, hasMore: start + 20 < TOTAL };
    },
    [],
  );
  return (
    <List isLoading={isLoading} pagination={pagination}>
      {(data ?? []).map((n: number) => (
        <List.Item key={n} title={`Item ${n + 1}`} subtitle={`page ${Math.floor(n / 20) + 1}`} />
      ))}
    </List>
  );
}
