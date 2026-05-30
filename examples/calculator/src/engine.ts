/**
 * Calculator engine — pure functions (PLAN.md §2 Calculator; SoulverCore is the licensed native
 * path, this is the open fallback engine scoped down per §3.3). Kept free of any @invoke/React
 * imports so it is unit-testable in isolation (see engine.test.ts).
 *
 * Handles, in priority order:
 *   1. currency:  "100 usd in eur"   (needs a rate table; live rates injected by the command)
 *   2. units:     "10 km in mi", "100 f to c", "1 kg in lb"
 *   3. math:      "2+2", "(3+4)*5", "2^10", "sqrt(16)", "10% of 200"
 */

export type CalcKind = "math" | "unit" | "currency";

export interface CalcResult {
  /** Formatted, copy-ready string (e.g. "1,024", "6.21 mi", "92.00 EUR"). */
  value: string;
  /** How the input was interpreted (shown as the subtitle). */
  detail: string;
  kind: CalcKind;
  /** The raw numeric result (for tests / further use). */
  raw: number;
}

/* ------------------------------------------------------------------ formatting */

function formatNumber(n: number, maxFractionDigits = 6): string {
  if (!isFinite(n)) return String(n);
  const rounded = Number(n.toFixed(maxFractionDigits));
  return rounded.toLocaleString("en-US", { maximumFractionDigits: maxFractionDigits });
}

/* ------------------------------------------------------------------ math evaluator */

type Token = { t: "num"; v: number } | { t: "op"; v: string } | { t: "id"; v: string };

function tokenize(input: string): Token[] | null {
  const tokens: Token[] = [];
  let i = 0;
  const s = input.replace(/×/g, "*").replace(/÷/g, "/").replace(/−/g, "-");
  while (i < s.length) {
    const c = s[i];
    if (c === " " || c === "\t" || c === ",") { i++; continue; }
    if ((c >= "0" && c <= "9") || c === ".") {
      let j = i + 1;
      while (j < s.length && ((s[j] >= "0" && s[j] <= "9") || s[j] === ".")) j++;
      const num = Number(s.slice(i, j));
      if (isNaN(num)) return null;
      tokens.push({ t: "num", v: num });
      i = j;
      continue;
    }
    if (/[a-zA-Z]/.test(c)) {
      let j = i + 1;
      while (j < s.length && /[a-zA-Z0-9]/.test(s[j])) j++;
      tokens.push({ t: "id", v: s.slice(i, j).toLowerCase() });
      i = j;
      continue;
    }
    if ("+-*/^()%".includes(c)) { tokens.push({ t: "op", v: c }); i++; continue; }
    return null; // unexpected character
  }
  return tokens;
}

const CONSTANTS: Record<string, number> = { pi: Math.PI, e: Math.E, tau: Math.PI * 2 };
const FUNCTIONS: Record<string, (x: number) => number> = {
  sqrt: Math.sqrt, cbrt: Math.cbrt, abs: Math.abs, round: Math.round, floor: Math.floor,
  ceil: Math.ceil, sin: Math.sin, cos: Math.cos, tan: Math.tan, asin: Math.asin, acos: Math.acos,
  atan: Math.atan, exp: Math.exp, log: Math.log10, log2: Math.log2, ln: Math.log,
};

/** Recursive-descent evaluator. Returns null on any parse/eval error. */
function evalMath(input: string): number | null {
  const tokens = tokenize(input);
  if (!tokens || tokens.length === 0) return null;
  let pos = 0;
  const peek = (): Token | undefined => tokens[pos];
  const eat = (): Token => tokens[pos++];

  let failed = false;
  const fail = (): number => { failed = true; return NaN; };

  // expr := term (('+'|'-') term)*
  function expr(): number {
    let left = term();
    while (!failed && peek()?.t === "op" && (peek() as { v: string }).v.match(/[+-]/)) {
      const op = (eat() as { v: string }).v;
      const right = term();
      left = op === "+" ? left + right : left - right;
    }
    return left;
  }
  // term := unary (('*'|'/'|'of') unary)*
  function term(): number {
    let left = unary();
    while (!failed) {
      const p = peek();
      if (p?.t === "op" && (p.v === "*" || p.v === "/")) {
        const op = (eat() as { v: string }).v;
        const right = unary();
        left = op === "*" ? left * right : left / right;
      } else if (p?.t === "id" && p.v === "of") {
        eat();
        left = left * unary(); // "20% of 200" → 0.2 * 200
      } else break;
    }
    return left;
  }
  // unary := ('-'|'+') unary | power
  function unary(): number {
    const p = peek();
    if (p?.t === "op" && (p.v === "-" || p.v === "+")) {
      eat();
      const v = unary();
      return p.v === "-" ? -v : v;
    }
    return power();
  }
  // power := postfix ('^' unary)?   (right-assoc)
  function power(): number {
    const base = postfix();
    if (!failed && peek()?.t === "op" && (peek() as { v: string }).v === "^") {
      eat();
      return Math.pow(base, unary());
    }
    return base;
  }
  // postfix := primary '%'*
  function postfix(): number {
    let v = primary();
    while (!failed && peek()?.t === "op" && (peek() as { v: string }).v === "%") {
      eat();
      v = v / 100;
    }
    return v;
  }
  // primary := num | '(' expr ')' | const | func '(' expr ')'
  function primary(): number {
    const p = peek();
    if (!p) return fail();
    if (p.t === "num") { eat(); return p.v; }
    if (p.t === "op" && p.v === "(") {
      eat();
      const v = expr();
      if (peek()?.t === "op" && (peek() as { v: string }).v === ")") eat(); else return fail();
      return v;
    }
    if (p.t === "id") {
      eat();
      if (p.v in CONSTANTS) return CONSTANTS[p.v];
      if (p.v in FUNCTIONS && peek()?.t === "op" && (peek() as { v: string }).v === "(") {
        eat();
        const arg = expr();
        if (peek()?.t === "op" && (peek() as { v: string }).v === ")") eat(); else return fail();
        return FUNCTIONS[p.v](arg);
      }
      return fail(); // unknown identifier
    }
    return fail();
  }

  const result = expr();
  if (failed || pos !== tokens.length || isNaN(result) || !isFinite(result)) return null;
  return result;
}

/* ------------------------------------------------------------------ unit conversion */

// Linear units: alias → [category, factor-to-base].
const LINEAR_UNITS: Record<string, [string, number]> = {
  // length (base: meter)
  mm: ["length", 0.001], cm: ["length", 0.01], m: ["length", 1], meter: ["length", 1], meters: ["length", 1],
  km: ["length", 1000], in: ["length", 0.0254], inch: ["length", 0.0254], inches: ["length", 0.0254],
  ft: ["length", 0.3048], foot: ["length", 0.3048], feet: ["length", 0.3048], yd: ["length", 0.9144],
  yard: ["length", 0.9144], yards: ["length", 0.9144], mi: ["length", 1609.344], mile: ["length", 1609.344],
  miles: ["length", 1609.344], nmi: ["length", 1852],
  // mass (base: gram)
  mg: ["mass", 0.001], g: ["mass", 1], gram: ["mass", 1], grams: ["mass", 1], kg: ["mass", 1000],
  lb: ["mass", 453.59237], lbs: ["mass", 453.59237], pound: ["mass", 453.59237], pounds: ["mass", 453.59237],
  oz: ["mass", 28.349523], ounce: ["mass", 28.349523], st: ["mass", 6350.29], ton: ["mass", 1_000_000],
  tonne: ["mass", 1_000_000], t: ["mass", 1_000_000],
  // data (base: byte)
  b: ["data", 1], byte: ["data", 1], bytes: ["data", 1], kb: ["data", 1e3], mb: ["data", 1e6],
  gb: ["data", 1e9], tb: ["data", 1e12], kib: ["data", 1024], mib: ["data", 1024 ** 2],
  gib: ["data", 1024 ** 3], tib: ["data", 1024 ** 4],
  // time (base: second)
  ms: ["time", 0.001], s: ["time", 1], sec: ["time", 1], secs: ["time", 1], second: ["time", 1],
  seconds: ["time", 1], min: ["time", 60], mins: ["time", 60], minute: ["time", 60], minutes: ["time", 60],
  h: ["time", 3600], hr: ["time", 3600], hour: ["time", 3600], hours: ["time", 3600], day: ["time", 86400],
  days: ["time", 86400], week: ["time", 604800], weeks: ["time", 604800],
  // speed (base: m/s)
  mph: ["speed", 0.44704], kph: ["speed", 0.277778], kmh: ["speed", 0.277778], knot: ["speed", 0.514444],
  knots: ["speed", 0.514444],
};

const TEMP_UNITS = new Set(["c", "celsius", "f", "fahrenheit", "k", "kelvin"]);

function toCelsius(v: number, u: string): number {
  if (u === "f" || u === "fahrenheit") return ((v - 32) * 5) / 9;
  if (u === "k" || u === "kelvin") return v - 273.15;
  return v;
}
function fromCelsius(c: number, u: string): number {
  if (u === "f" || u === "fahrenheit") return (c * 9) / 5 + 32;
  if (u === "k" || u === "kelvin") return c + 273.15;
  return c;
}

function convertUnit(amount: number, from: string, to: string): { value: number; unit: string } | null {
  const a = from.toLowerCase();
  const b = to.toLowerCase();
  if (TEMP_UNITS.has(a) && TEMP_UNITS.has(b)) {
    return { value: fromCelsius(toCelsius(amount, a), b), unit: to };
  }
  const ua = LINEAR_UNITS[a];
  const ub = LINEAR_UNITS[b];
  if (ua && ub && ua[0] === ub[0]) {
    return { value: (amount * ua[1]) / ub[1], unit: to };
  }
  return null;
}

/* ------------------------------------------------------------------ currency */

/** Approximate offline fallback rates as "units per 1 USD" (live rates injected by the command). */
export const STATIC_RATES: Record<string, number> = {
  USD: 1, EUR: 0.92, GBP: 0.79, INR: 83.3, JPY: 157, AUD: 1.51, CAD: 1.37,
  CHF: 0.89, CNY: 7.24, AED: 3.67, SGD: 1.35, HKD: 7.81, NZD: 1.64,
};

/**
 * Build a USD-based rate table ("units per 1 USD") from a Frankfurter-style response, normalizing
 * whatever base the API returns, and MERGING over the static table so currencies the live feed
 * omits (the ECB set has no AED, etc.) keep a fallback rather than vanishing.
 */
export function usdRatesFrom(resp: { base?: string; rates?: Record<string, number> } | undefined): Record<string, number> {
  const live = resp?.rates;
  if (!live) return { ...STATIC_RATES };

  const base = (resp?.base ?? "USD").toUpperCase();
  const perBase = { ...live, [base]: 1 }; // values are "X per 1 base"; the base itself is 1
  const usdPerBase = perBase["USD"];
  if (!usdPerBase) {
    // No USD anchor to normalize against — best effort: trust the values, keep static fallbacks.
    return { ...STATIC_RATES, ...perBase, USD: 1 };
  }
  const usd: Record<string, number> = {};
  for (const code in perBase) usd[code] = perBase[code] / usdPerBase; // (X per base)/(USD per base) = X per USD
  usd["USD"] = 1;
  return { ...STATIC_RATES, ...usd }; // live overrides static where present; static fills the gaps (AED…)
}

function convertCurrency(
  amount: number,
  from: string,
  to: string,
  rates: Record<string, number>,
): number | null {
  const a = from.toUpperCase();
  const b = to.toUpperCase();
  if (rates[a] == null || rates[b] == null) return null;
  const usd = amount / rates[a];
  return usd * rates[b];
}

/* ------------------------------------------------------------------ dispatcher */

const CONVERSION_RE = /^\s*(-?[\d.,]+)\s*([a-zA-Z°]{1,12})\s+(?:in|to|as)\s+([a-zA-Z°]{1,12})\s*$/i;

export function calculate(input: string, rates: Record<string, number> = STATIC_RATES): CalcResult | null {
  const trimmed = input.trim();
  if (!trimmed) return null;

  const conv = trimmed.match(CONVERSION_RE);
  if (conv) {
    const amount = Number(conv[1].replace(/,/g, ""));
    const from = conv[2];
    const to = conv[3];
    if (!isNaN(amount)) {
      // currency first (3-letter codes present in the rate table), else units
      if (from.length === 3 && to.length === 3 && rates[from.toUpperCase()] != null && rates[to.toUpperCase()] != null) {
        const c = convertCurrency(amount, from, to, rates);
        if (c != null) {
          return { value: `${formatNumber(c, 2)} ${to.toUpperCase()}`, detail: `${formatNumber(amount, 2)} ${from.toUpperCase()} → ${to.toUpperCase()}`, kind: "currency", raw: c };
        }
      }
      const u = convertUnit(amount, from, to);
      if (u != null) {
        return { value: `${formatNumber(u.value)} ${to}`, detail: `${formatNumber(amount)} ${from} → ${to}`, kind: "unit", raw: u.value };
      }
      return null; // looked like a conversion but units/codes unknown
    }
  }

  const m = evalMath(trimmed);
  if (m != null) {
    return { value: formatNumber(m), detail: trimmed, kind: "math", raw: m };
  }
  return null;
}
