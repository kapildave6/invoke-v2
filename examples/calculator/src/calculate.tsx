/**
 * Calculator `view` command (PLAN.md §2). Reads the root search text and shows a computed result —
 * math, unit conversion, or live currency conversion. The heavy lifting is in the pure `engine`;
 * this component just supplies live FX rates and renders.
 */
import { List, ActionPanel, Action } from "@invoke/api";
import { useFetch } from "@invoke/utils";
import { useState } from "react";
import { calculate, usdRatesFrom } from "./engine.ts";

interface RatesResponse {
  base_code?: string;
  rates?: Record<string, number>;
}

export default function Command() {
  const [query, setQuery] = useState("");

  // Live rates with broad coverage (~160 currencies incl. AED and the rest of the GCC), free + no
  // key, daily updates. usdRatesFrom() normalizes to a USD base and merges the static table only as
  // an OFFLINE fallback — so in normal use every rate is live, not hard-coded.
  const { data } = useFetch<RatesResponse>("https://open.er-api.com/v6/latest/USD");
  const rates = usdRatesFrom({ base: data?.base_code, rates: data?.rates });

  const result = calculate(query, rates);

  return (
    <List
      searchBarPlaceholder="Calculate — e.g. 2+2, 10 km in mi, 100 usd in eur"
      onSearchTextChange={setQuery}
      filtering={false}
    >
      {result ? (
        <List.Section title="Calculator">
          <List.Item
            title={result.value}
            subtitle={result.detail}
            display="card"
            card={{
              left: result.left,
              right: result.right,
              leftLabel: result.leftLabel ?? "",
              rightLabel: result.rightLabel ?? "",
              kind: result.kind,
              note: result.kind === "currency" ? "Live rate" : "",
            }}
            actions={
              <ActionPanel>
                <Action.CopyToClipboard content={result.value} />
              </ActionPanel>
            }
          />
        </List.Section>
      ) : (
        <List.Item
          title={query.trim() ? "No result" : "Type a calculation"}
          subtitle="2+2  ·  10 km in mi  ·  100 f to c  ·  100 usd in eur"
        />
      )}
    </List>
  );
}
