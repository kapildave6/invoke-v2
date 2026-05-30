/**
 * Calculator engine tests. Pure logic, no runtime needed: `npx tsx examples/calculator/src/engine.test.ts`
 * (wired as `npm run test:calc`). Compares the raw numeric result within a tolerance so formatting
 * choices don't make tests brittle; exits non-zero on any failure (CI gate).
 */
import { calculate, usdRatesFrom, STATIC_RATES } from "./engine.ts";

let pass = 0;
let fail = 0;

function approx(input: string, expected: number, eps = 1e-4): void {
  const r = calculate(input, STATIC_RATES);
  if (r == null) {
    fail++;
    console.error(`FAIL "${input}" → null, expected ≈ ${expected}`);
    return;
  }
  if (Math.abs(r.raw - expected) <= eps * Math.max(1, Math.abs(expected))) {
    pass++;
  } else {
    fail++;
    console.error(`FAIL "${input}" → ${r.raw} (${r.value}), expected ≈ ${expected}`);
  }
}

function isNull(input: string): void {
  const r = calculate(input, STATIC_RATES);
  if (r == null) pass++;
  else { fail++; console.error(`FAIL "${input}" → ${r.value}, expected null`); }
}

function kind(input: string, k: string): void {
  const r = calculate(input, STATIC_RATES);
  if (r?.kind === k) pass++;
  else { fail++; console.error(`FAIL "${input}" → kind ${r?.kind}, expected ${k}`); }
}

// ── math ──
approx("2+2", 4);
approx("(3+4)*5", 35);
approx("2^10", 1024);
approx("2^2^3", 256); // right-assoc: 2^(2^3)
approx("sqrt(16)", 4);
approx("10/4", 2.5);
approx("-5 + 3", -2);
approx("3 + 4 * 2", 11); // precedence
approx("(1+2)*(3+4)", 21);
approx("10% of 200", 20);
approx("50% of 50% of 100", 25);
approx("100 * 1.5%", 1.5);
approx("abs(-7)", 7);
approx("round(3.6)", 4);
approx("pi", Math.PI);
approx("2 * pi", Math.PI * 2);
approx("ln(e)", 1);
approx("log(1000)", 3);

// ── units ──
approx("10 km in mi", 6.2137119);
approx("1 mi in km", 1.609344);
approx("100 cm in m", 1);
approx("1 kg in lb", 2.2046226);
approx("16 oz in lb", 1);
approx("100 f to c", 37.77778);
approx("0 c in f", 32);
approx("300 k in c", 26.85);
approx("1 gb in mb", 1000);
approx("1 gib in mib", 1024);
approx("1 hour in min", 60);
approx("60 mph in kph", 96.56064, 1e-2);

// ── currency (static fallback table) ──
approx("100 usd in eur", 92);
approx("100 eur in usd", 108.69565, 1e-3);
approx("10 usd in inr", 833);
approx("100 usd in aed", 367); // AED is pegged; static fallback (not in the ECB feed)
approx("367 aed in usd", 100, 1e-3);
kind("100 usd in eur", "currency");
kind("10 km in mi", "unit");
kind("2+2", "math");

// ── non-results ──
isNull("");
isNull("hello world");
isNull("5 xyz in abc");
isNull("10 km in kg"); // category mismatch
isNull("2 +"); // incomplete

// ── usdRatesFrom: live-rate normalization + static merge (the AED bug fix) ──
function rateEq(label: string, got: number | undefined, expected: number, eps = 1e-4): void {
  if (got != null && Math.abs(got - expected) <= eps * Math.max(1, Math.abs(expected))) pass++;
  else { fail++; console.error(`FAIL rate ${label} → ${got}, expected ≈ ${expected}`); }
}
// USD-based response (AED absent from feed) must keep AED from the static fallback.
{
  const r = usdRatesFrom({ base: "USD", rates: { EUR: 0.9, INR: 84 } });
  rateEq("USD-base USD", r.USD, 1);
  rateEq("USD-base EUR", r.EUR, 0.9);
  rateEq("USD-base AED(static)", r.AED, STATIC_RATES.AED);
}
// EUR-based response must be normalized to a USD base.
{
  const r = usdRatesFrom({ base: "EUR", rates: { USD: 1.1, GBP: 0.85 } });
  rateEq("EUR-base USD", r.USD, 1);
  rateEq("EUR-base EUR", r.EUR, 1 / 1.1);
  rateEq("EUR-base GBP", r.GBP, 0.85 / 1.1);
  rateEq("EUR-base AED(static)", r.AED, STATIC_RATES.AED);
}
// Broad live feed (open.er-api shape: USD base, includes AED) → live AED overrides the static one.
{
  const r = usdRatesFrom({ base: "USD", rates: { USD: 1, AED: 3.6725, EUR: 0.93, KWD: 0.307 } });
  rateEq("live AED (overrides static)", r.AED, 3.6725);
  rateEq("live KWD (not in static)", r.KWD, 0.307);
  rateEq("live EUR", r.EUR, 0.93);
}
// No response / no rates → static table (offline fallback).
rateEq("no-response AED", usdRatesFrom(undefined).AED, STATIC_RATES.AED);
rateEq("no-rates AED", usdRatesFrom({ base: "USD" }).AED, STATIC_RATES.AED);

console.log(`\ncalc engine: ${pass} passed, ${fail} failed`);
if (fail > 0) process.exit(1);
console.log("✓ all calculator engine tests passed");
