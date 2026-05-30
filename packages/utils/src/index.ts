/**
 * @invoke/utils — hooks & helpers (PLAN.md §5.4).
 *
 * All data hooks center on the same shape: { data, isLoading, error, revalidate }.
 * Minimal but real implementations so extensions (and the conformance suite) can
 * depend on them; richer caching/pagination/mutate land in Phase 3.
 */
import { useCallback, useEffect, useRef, useState } from "react";

export interface AsyncState<T> {
  data: T | undefined;
  isLoading: boolean;
  error: Error | undefined;
  revalidate: () => void;
}

export function usePromise<T>(fn: () => Promise<T>, deps: unknown[] = []): AsyncState<T> {
  const [data, setData] = useState<T | undefined>(undefined);
  const [isLoading, setLoading] = useState(true);
  const [error, setError] = useState<Error | undefined>(undefined);
  const [nonce, setNonce] = useState(0);
  const latest = useRef(0);

  useEffect(() => {
    const run = ++latest.current;
    setLoading(true);
    setError(undefined);
    fn()
      .then((d) => {
        if (run === latest.current) {
          setData(d);
          setLoading(false);
        }
      })
      .catch((e: unknown) => {
        if (run === latest.current) {
          setError(e instanceof Error ? e : new Error(String(e)));
          setLoading(false);
        }
      });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [nonce, ...deps]);

  const revalidate = useCallback(() => setNonce((n) => n + 1), []);
  return { data, isLoading, error, revalidate };
}

export function useFetch<T = unknown>(url: string, init?: RequestInit): AsyncState<T> {
  return usePromise<T>(async () => {
    const res = await fetch(url, init);
    if (!res.ok) throw new Error(`${res.status} ${res.statusText}`);
    return (await res.json()) as T;
  }, [url]);
}

/** Process-local cached state (production: backed by the host's Cache, PLAN.md §5.5). */
const cacheStore = new Map<string, unknown>();
export function useCachedState<T>(key: string, initial: T): [T, (v: T | ((p: T) => T)) => void] {
  const [value, setValue] = useState<T>(() => (cacheStore.has(key) ? (cacheStore.get(key) as T) : initial));
  const set = useCallback(
    (v: T | ((p: T) => T)) =>
      setValue((prev) => {
        const next = typeof v === "function" ? (v as (p: T) => T)(prev) : v;
        cacheStore.set(key, next);
        return next;
      }),
    [key],
  );
  return [value, set];
}

export async function showFailureToast(error: unknown, opts?: { title?: string }): Promise<void> {
  const message = error instanceof Error ? error.message : String(error);
  // Lazy import to avoid a hard dependency cycle with @invoke/api.
  const api = await import("@invoke/api");
  await api.showToast({ style: api.Toast.Style.Failure, title: opts?.title ?? "Something went wrong", message });
}
