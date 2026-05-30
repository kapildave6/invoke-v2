/**
 * Calculator `view` command (PLAN.md §2). Reads the root search text and shows a computed result —
 * math, unit conversion, or live currency conversion. The heavy lifting is in the pure `engine`;
 * this component just supplies live FX rates and renders.
 */
import { List, ActionPanel, Action } from "@invoke/api";
import { useFetch } from "@invoke/utils";
import { useState } from "react";
import { calculate, STATIC_RATES } from "./engine.ts";

interface FrankfurterResponse {
  rates: Record<string, number>;
}

export default function Command() {
  const [query, setQuery] = useState("");

  // Live ECB rates (free, no key); falls back to the static table offline / on error.
  const { data } = useFetch<FrankfurterResponse>("https://api.frankfurter.app/latest?base=USD");
  const rates = data?.rates ? { USD: 1, ...data.rates } : STATIC_RATES;

  const result = calculate(query, rates);

  return (
    <List
      searchBarPlaceholder="Calculate — e.g. 2+2, 10 km in mi, 100 usd in eur"
      onSearchTextChange={setQuery}
      filtering={false}
    >
      {result ? (
        <List.Item
          title={result.value}
          subtitle={result.detail}
          accessories={[{ tag: result.kind }]}
          actions={
            <ActionPanel>
              <Action.CopyToClipboard content={result.value} />
            </ActionPanel>
          }
        />
      ) : (
        <List.Item
          title={query.trim() ? "No result" : "Type a calculation"}
          subtitle="2+2  ·  10 km in mi  ·  100 f to c  ·  100 usd in eur"
        />
      )}
    </List>
  );
}
