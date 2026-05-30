/**
 * Calculator `view` command (PLAN.md §2). Reads the root search text and shows a computed result —
 * math, unit conversion, or live currency conversion. The heavy lifting is in the pure `engine`;
 * this component just supplies live FX rates and renders.
 */
import { List, ActionPanel, Action } from "@invoke/api";
import { useFetch } from "@invoke/utils";
import { useState } from "react";
import { calculate, usdRatesFrom } from "./engine.ts";

interface FrankfurterResponse {
  base?: string;
  rates: Record<string, number>;
}

export default function Command() {
  const [query, setQuery] = useState("");

  // Live ECB rates (free, no key). usdRatesFrom() normalizes to a USD base and MERGES the static
  // table underneath, so currencies the ECB feed omits (e.g. AED) still convert.
  const { data } = useFetch<FrankfurterResponse>("https://api.frankfurter.app/latest?base=USD");
  const rates = usdRatesFrom(data);

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
