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

/** Run an AppleScript via the host (Raycast's @raycast/utils runAppleScript). */
export async function runAppleScript(source: string): Promise<string> {
  const api = await import("@invoke/api");
  return api.runAppleScript(source);
}

/* ------------------------------------------------------------------ SQL (read-only)
 * Raycast's useSQL/executeSQL read a local SQLite file directly. In Invoke that file access is a
 * HOST-mediated, consent-gated, read-only capability (the sandboxed child has no fs) — the query runs
 * in the Swift host with ATTACH and non-SELECT statements denied (PLAN.md §4.4). */

/** Run a read-only SQL query against a local SQLite file via the host. Resolves to the rows. */
export async function executeSQL<T = unknown>(databasePath: string, query: string): Promise<T[]> {
  const api = await import("@invoke/api");
  return (await api.executeSQL(databasePath, query)) as T[];
}

export interface UseSQLOptions<T> {
  /** Skip running the query (e.g. until a dependency is ready). Defaults to true. */
  execute?: boolean;
  /** Shown by Raycast as a permission-priming view; Invoke gates via the host consent dialog instead. */
  permissionPriming?: string;
  onError?: (error: Error) => void;
  onData?: (data: T[]) => void;
}

/** Reactive read-only SQL query — `{ data, isLoading, error, revalidate, permissionView }`. */
export function useSQL<T = unknown>(
  databasePath: string,
  query: string,
  options: UseSQLOptions<T> = {},
): AsyncState<T[]> & { permissionView: undefined } {
  // Callers commonly gate with `execute: data && data.length > 0`, which is `undefined` (not `false`)
  // before the parent query resolves. Treat an explicitly-passed `execute` as a real boolean so a
  // falsy-but-not-false value still skips, rather than `?? true` letting the gated query run early.
  const execute = "execute" in options ? Boolean(options.execute) : true;
  const state = usePromise<T[]>(
    async () => (execute ? executeSQL<T>(databasePath, query) : ([] as T[])),
    [databasePath, query, execute],
  );
  const { error, data } = state;
  useEffect(() => {
    if (error) options.onError?.(error);
  }, [error]); // eslint-disable-line react-hooks/exhaustive-deps
  useEffect(() => {
    if (data) options.onData?.(data);
  }, [data]); // eslint-disable-line react-hooks/exhaustive-deps
  // Raycast surfaces a permissionView when access is denied; Invoke handles consent in the host dialog,
  // so there's nothing to render here — but the field must exist so destructuring/spreading is safe.
  return { ...state, permissionView: undefined };
}

/* ------------------------------------------------------------------ useCachedPromise
 * Like usePromise, but the dependency tuple is also the argument list passed to `fn`. (Our cache layer
 * is the same process-local store as useCachedState; cross-session persistence lands with the host Cache.) */
export function useCachedPromise<T, A extends unknown[] = unknown[]>(
  fn: (...args: A) => Promise<T>,
  args: A = [] as unknown as A,
  _options?: { initialData?: T; keepPreviousData?: boolean; onError?: (e: Error) => void },
): AsyncState<T> {
  // Depend on a STRUCTURAL key of args, not the array's identity: callers routinely pass a fresh
  // literal each render (e.g. [note.id]); spreading that straight into deps re-runs the effect every
  // render → infinite refetch loop when an element is itself a fresh object. Call fn with the latest
  // args via a ref so the data stays current without widening the dependency.
  let key: string;
  try {
    key = JSON.stringify(args);
  } catch {
    key = String(args.length);
  }
  const argsRef = useRef(args);
  argsRef.current = args;
  return usePromise<T>(() => fn(...(argsRef.current as A)), [key]);
}

/* ------------------------------------------------------------------ useForm
 * Minimal but real port of Raycast's useForm: controlled values + validation, returning `itemProps`
 * to spread onto Form fields. Our Form fields are host-rendered and collect their values on submit, so
 * handleSubmit validates the host-collected values (its argument) and falls back to internal state. */
export const FormValidation = { Required: "required" } as const;

type Validator<V> = ((value: V) => string | undefined | null) | "required";

export interface UseFormProps<T extends Record<string, unknown>> {
  onSubmit: (values: T) => void | boolean | Promise<void | boolean>;
  initialValues?: Partial<T>;
  validation?: { [K in keyof T]?: Validator<T[K]> };
}

export interface FormItemProps<V> {
  id: string;
  value: V;
  onChange: (value: V) => void;
  error: string | undefined;
}

export function useForm<T extends Record<string, unknown>>(props: UseFormProps<T>) {
  const [values, setValues] = useState<T>(() => ({ ...(props.initialValues ?? {}) }) as T);
  const [errors, setErrors] = useState<{ [K in keyof T]?: string }>({});

  const setValue = useCallback(<K extends keyof T>(id: K, value: T[K]) => {
    setValues((prev) => ({ ...prev, [id]: value }));
  }, []);

  const validate = useCallback(
    (vals: T): boolean => {
      const next: { [K in keyof T]?: string } = {};
      let ok = true;
      for (const key in props.validation) {
        const rule = props.validation[key];
        const v = vals[key];
        let message: string | undefined | null;
        if (rule === "required") {
          const empty = v === undefined || v === null || v === "" || v === false;
          message = empty ? "The item is required" : undefined;
        } else if (typeof rule === "function") {
          message = rule(v as T[typeof key]);
        }
        if (message) {
          next[key] = message;
          ok = false;
        }
      }
      setErrors(next);
      return ok;
    },
    [props.validation],
  );

  const handleSubmit = useCallback(
    (submitted?: T): boolean => {
      const vals = (submitted ?? values) as T;
      if (!validate(vals)) return false;
      void props.onSubmit(vals);
      return true;
    },
    [values, validate, props],
  );

  const reset = useCallback(
    (newValues?: Partial<T>) => {
      setValues({ ...(newValues ?? props.initialValues ?? {}) } as T);
      setErrors({});
    },
    [props.initialValues],
  );

  // `itemProps.<field>` lazily yields { id, value, onChange, error } for any accessed field name.
  const itemProps = new Proxy({} as { [K in keyof T]: FormItemProps<T[K]> }, {
    get: (_t, id) => {
      if (typeof id !== "string") return undefined;
      return {
        id,
        value: (values as Record<string, unknown>)[id],
        onChange: (value: unknown) => setValue(id as keyof T, value as T[keyof T]),
        error: (errors as Record<string, string | undefined>)[id],
      };
    },
  });

  return { values, setValue, errors, itemProps, handleSubmit, reset, focus: () => {} };
}
