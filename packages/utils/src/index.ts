/**
 * @invoke/utils — hooks & helpers (PLAN.md §5.4).
 *
 * All data hooks center on the same shape: { data, isLoading, error, revalidate }.
 * Minimal but real implementations so extensions (and the conformance suite) can
 * depend on them; richer caching/pagination/mutate land in Phase 3.
 */
import { createElement, useCallback, useEffect, useRef, useState, type ComponentType, type ReactNode } from "react";

export interface AsyncState<T> {
  data: T | undefined;
  isLoading: boolean;
  error: Error | undefined;
  revalidate: () => void;
}

export interface PaginationOptions {
  pageSize: number;
  hasMore: boolean;
  onLoadMore: () => void;
}

/** Merge a freshly-fetched page into the accumulated list: page 0 replaces (a deps reset), later pages append. */
export function mergePages<T>(existing: T[], pageData: T[], page: number): T[] {
  return page === 0 ? pageData : existing.concat(pageData);
}

export function usePromise<T>(
  fn: (...args: unknown[]) => Promise<T> | ((opts: { page: number }) => Promise<{ data: T; hasMore?: boolean }>),
  deps: unknown[] = [],
): AsyncState<T> & { mutate: MutatePromise<T>; pagination?: PaginationOptions } {
  const [data, setData] = useState<T | undefined>(undefined);
  const dataRef = useRef(data);
  dataRef.current = data;
  const [isLoading, setLoading] = useState(true);
  const [error, setError] = useState<Error | undefined>(undefined);
  const [nonce, setNonce] = useState(0);
  const [hasMore, setHasMore] = useState(false);
  const [paginated, setPaginated] = useState(false);
  const [pageSize, setPageSize] = useState(0);
  const page = useRef(0);
  const acc = useRef<unknown[]>([]);
  const latest = useRef(0);

  const runPage = useCallback((p: number, run: number) => {
    Promise.resolve()
      .then(() => { const maybe: unknown = fn(...deps); return { maybe }; })
      .then(({ maybe }) => {
        if (typeof maybe === "function") {
          // Raycast paginated form: fn(...deps) returns an async fetcher of { page }.
          if (run === latest.current) setPaginated(true);
          return Promise.resolve((maybe as (o: { page: number }) => Promise<{ data: T; hasMore?: boolean }>)({ page: p })).then((res) => {
            if (run !== latest.current) return;
            const pageData = (res?.data ?? []) as unknown[];
            if (p === 0) setPageSize(Array.isArray(pageData) ? pageData.length : 0);
            acc.current = mergePages(acc.current, pageData, p);
            setData(acc.current as unknown as T);
            setHasMore(!!res?.hasMore);
            setLoading(false);
          });
        }
        // Non-paginated (today's behavior): fn(...deps) is the value/Promise itself.
        if (run === latest.current) setPaginated(false);
        return Promise.resolve(maybe as Promise<T>).then((d) => {
          if (run === latest.current) { setData(d); setLoading(false); }
        });
      })
      .catch((e: unknown) => {
        if (run === latest.current) { setError(e instanceof Error ? e : new Error(String(e))); setLoading(false); }
      });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps);

  useEffect(() => {
    const run = ++latest.current;
    setLoading(true); setError(undefined);
    page.current = 0; acc.current = [];
    runPage(0, run);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [nonce, ...deps]);

  const onLoadMore = useCallback(() => {
    if (!hasMore || isLoading) return;
    page.current += 1;
    setLoading(true);
    runPage(page.current, latest.current);
  }, [hasMore, isLoading, runPage]);

  const revalidate = useCallback(() => setNonce((n) => n + 1), []);
  const mutate: MutatePromise<T> = async (asyncUpdate, opts) => {
    const rollback = dataRef.current;
    if (opts?.optimisticUpdate) setData(opts.optimisticUpdate(dataRef.current as T));
    try {
      const r = asyncUpdate ? await asyncUpdate : undefined;
      if (opts?.shouldRevalidateAfter !== false) revalidate();
      return r as never;
    } catch (e) {
      if (opts?.rollbackOnError) {
        setData(typeof opts.rollbackOnError === "function" ? (opts.rollbackOnError as (d: T) => T)(rollback as T) : rollback);
      }
      throw e;
    }
  };
  const pagination = paginated ? { pageSize: pageSize || 50, hasMore, onLoadMore } : undefined;
  return { data, isLoading, error, revalidate, mutate, pagination };
}

/** Options for useFetch — mirrors the parts of Raycast's @raycast/utils useFetch extensions rely on. */
export interface UseFetchOptions<T = unknown, U = T> {
  method?: string;
  headers?: Record<string, string>;
  body?: BodyInit;
  signal?: AbortSignal;
  /** Turn the Response into the raw result. Default: `res.json()`. (Lets callers parse XML/text.) */
  parseResponse?: (response: Response) => Promise<T> | T;
  /** Map the parsed result to the exposed `data` (Raycast returns `{ data, hasMore? }`). */
  mapResult?: (result: T) => { data: U; hasMore?: boolean };
  /** Keep the last successful data while a new request is in flight (no flicker). */
  keepPreviousData?: boolean;
  /** Skip fetching until true (default true). */
  execute?: boolean;
  initialData?: U;
  onError?: (error: Error) => void;
  onData?: (data: U) => void;
}

export function useFetch<T = unknown, U = T>(
  url: string | ((opts: { page: number }) => string),
  options: UseFetchOptions<T, U> = {},
): AsyncState<U> & { pagination?: PaginationOptions } {
  const { parseResponse, mapResult, keepPreviousData, execute, initialData, onError, onData, method, headers, body, signal } = options;
  const shouldExecute = execute === undefined ? true : execute;
  const last = useRef<U | undefined>(initialData);

  const paginated = typeof url === "function";
  // Paginated mode: the `url` arg is a function (fresh identity every render) — key the effect on
  // the page-0 URL string instead so the effect only re-runs when the URL content changes (e.g.
  // searchText the fn closes over), not on every render (which would reset page→0 → refetch loop).
  const urlKey = paginated
    ? (url as (o: { page: number }) => string)({ page: 0 })
    : (url as string);

  const state = usePromise<U>(
    paginated
      ? (() => async ({ page }: { page: number }) => {
          const res = await fetch((url as (o: { page: number }) => string)({ page }), { method, headers, body, signal });
          if (!res.ok && !parseResponse) throw new Error(`${res.status} ${res.statusText}`);
          const parsed = (parseResponse ? await parseResponse(res) : await res.json()) as T;
          const mapped = mapResult ? mapResult(parsed) : { data: parsed as unknown as U, hasMore: false };
          return { data: mapped.data, hasMore: mapped.hasMore ?? false };
        })
      : (async () => {
          if (!shouldExecute) return (keepPreviousData ? last.current : initialData) as U;
          const res = await fetch(url as string, { method, headers, body, signal });
          // A custom parseResponse owns status handling (Raycast extensions often return an error string for
          // non-2xx); only throw on a bad status when there's no custom parser.
          if (!res.ok && !parseResponse) throw new Error(`${res.status} ${res.statusText}`);
          const parsed = parseResponse ? await parseResponse(res) : ((await res.json()) as T);
          const mapped = (mapResult ? mapResult(parsed).data : (parsed as unknown as U));
          last.current = mapped;
          return mapped;
        }),
    [urlKey, shouldExecute],
  );

  // keepPreviousData / initialData: surface the last good value while loading or after an error.
  // For the paginated path, data is already the accumulated array from usePromise — don't override it.
  const data = paginated ? state.data : (state.data ?? (keepPreviousData ? last.current : initialData));
  useEffect(() => { if (state.error) onError?.(state.error); }, [state.error]); // eslint-disable-line react-hooks/exhaustive-deps
  useEffect(() => { if (state.data !== undefined) onData?.(state.data); }, [state.data]); // eslint-disable-line react-hooks/exhaustive-deps
  return { ...state, data, pagination: state.pagination };
}

/* Cached state shared across hook instances AND persisted across launches (Raycast parity — Raycast
 * backs this with its Cache). The in-process Map keeps every instance of a key in sync synchronously;
 * a host LocalStorage entry persists it. On first mount of a key we hydrate from the host (one async
 * re-render); writes update the Map (sync), notify all instances, and write through to the host. */
const cacheStore = new Map<string, unknown>();
const cacheSubs = new Map<string, Set<() => void>>();
const cacheHydrated = new Set<string>();
const CACHED_STATE_PREFIX = "__cachedState__:";
function notifyCachedState(key: string): void { cacheSubs.get(key)?.forEach((fn) => fn()); }

export function useCachedState<T>(key: string, initial: T): [T, (v: T | ((p: T) => T)) => void] {
  const [, bump] = useState(0);
  useEffect(() => {
    let subs = cacheSubs.get(key);
    if (!subs) { subs = new Set(); cacheSubs.set(key, subs); }
    const cb = () => bump((n) => n + 1);
    subs.add(cb);
    if (!cacheHydrated.has(key)) {
      cacheHydrated.add(key);
      void (async () => {
        try {
          const api = await import("@invoke/api");
          const raw = await api.LocalStorage.getItem<string>(CACHED_STATE_PREFIX + key);
          if (raw != null && !cacheStore.has(key)) { // don't clobber a fresh in-session write
            cacheStore.set(key, JSON.parse(raw));
            notifyCachedState(key);
          }
        } catch { /* no host — in-memory only */ }
      })();
    }
    return () => { subs?.delete(cb); };
  }, [key]);

  const value = (cacheStore.has(key) ? cacheStore.get(key) : initial) as T;
  const set = useCallback(
    (v: T | ((p: T) => T)) => {
      const prev = (cacheStore.has(key) ? cacheStore.get(key) : initial) as T;
      const next = typeof v === "function" ? (v as (p: T) => T)(prev) : v;
      cacheStore.set(key, next);
      notifyCachedState(key); // sync every instance of this key in-process
      void (async () => {
        try {
          const api = await import("@invoke/api");
          await api.LocalStorage.setItem(CACHED_STATE_PREFIX + key, JSON.stringify(next));
        } catch { /* no host — in-memory only */ }
      })();
    },
    [key], // eslint-disable-line react-hooks/exhaustive-deps
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

/* ------------------------------------------------------------------ useExec
 * Run a local command and surface its output (Raycast's @raycast/utils useExec). This spawns a
 * subprocess via node:child_process — only available to a USER-TRUSTED, unsandboxed extension; in a
 * sandboxed extension the child_process import is denied and this resolves to an error state. The
 * import is lazy so merely loading @invoke/utils never trips the sandbox. */
export interface UseExecOptions {
  cwd?: string;
  env?: Record<string, string>;
  shell?: boolean | string;
  input?: string;
  // Raycast passes the FULL result to parseOutput (not just stdout/stderr) and lets the extension decide
  // success/failure — many CLI extensions branch on exitCode/error here (e.g. 1Password's `if (exitCode
  // != 0) handleErrors(stdout)`). Omitting exitCode made `undefined != 0` always true → valid output was
  // thrown as an error on every call.
  parseOutput?: (args: {
    stdout: string;
    stderr: string;
    error?: Error;
    exitCode: number | null;
    signal: NodeJS.Signals | null;
    timedOut: boolean;
    command: string;
  }) => unknown;
}
export function useExec<T = string>(
  command: string,
  args: string[] = [],
  options: UseExecOptions = {},
): AsyncState<T> {
  return usePromise<T>(async () => {
    const cp = (await import("node:child_process")) as typeof import("node:child_process");
    return new Promise<T>((resolve, reject) => {
      const child = cp.execFile(
        command,
        args,
        { cwd: options.cwd, env: options.env ? { ...process.env, ...options.env } : undefined,
          shell: options.shell, maxBuffer: 32 * 1024 * 1024, encoding: "utf8" },
        (err, stdout, stderr) => {
          const out = typeof stdout === "string" ? stdout : String(stdout);
          const errOut = typeof stderr === "string" ? stderr : String(stderr);
          // Match Raycast: hand the full result to parseOutput and let it decide. exitCode is 0 on
          // success (so `exitCode != 0` is correctly false); a non-zero/spawn error still goes to
          // parseOutput so the extension's own error handling runs (it often reads stdout on failure).
          const e = err as (Error & { code?: number | string; signal?: NodeJS.Signals; killed?: boolean }) | null;
          const exitCode: number | null = e == null ? 0 : typeof e.code === "number" ? e.code : null;
          if (options.parseOutput) {
            try {
              resolve(options.parseOutput({
                stdout: out,
                stderr: errOut,
                error: e ?? undefined,
                exitCode,
                signal: e?.signal ?? null,
                timedOut: e?.killed ?? false,
                command: [command, ...args].join(" "),
              }) as T);
            } catch (perr) {
              reject(perr); // parseOutput threw (e.g. handleErrors) → surface it as the hook's error
            }
            return;
          }
          if (e) return reject(e);
          resolve(out as T);
        },
      );
      if (options.input != null && child.stdin) { child.stdin.write(options.input); child.stdin.end(); }
    });
  }, [command, JSON.stringify(args)]);
}

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
  fn: (...args: A) => Promise<T> | (() => Promise<T>) | T | ((opts: { page: number }) => Promise<{ data: T; hasMore?: boolean }>),
  args: A = [] as unknown as A,
  options?: { initialData?: T; keepPreviousData?: boolean; onError?: (e: Error) => void },
): AsyncState<T> & { mutate: MutatePromise<T>; pagination?: PaginationOptions } {
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
  // Build an inner fn that usePromise can call. usePromise calls fn(...deps) where deps=[key] here.
  // We ignore the key arg and forward to the real fn via argsRef to keep args current.
  // If fn(...args) returns a page-fetcher function (paginated curried form), we return it directly
  // so usePromise's paginated detection fires and accumulates pages.
  // If fn(...args) returns a thunk (() => Promise<T>, length 0) we call it (non-paginated path).
  // If fn(...args) returns a value/Promise directly, we handle {data,hasMore} unwrapping as before.
  const innerFn = (..._deps: unknown[]): unknown => {
    const result = fn(...(argsRef.current as A)) as unknown;
    if (typeof result === "function") {
      // Paginated curried form: fn(...args) → async ({page}) => {data, hasMore}.
      // usePromise detects this by typeof === "function" and calls it with { page }; just return it.
      return result;
    }
    // Non-function result: handle {data, hasMore} shape convention for non-paginated path.
    return Promise.resolve(result).then((resolved) => {
      if (resolved && typeof resolved === "object" && "data" in (resolved as Record<string, unknown>) && !Array.isArray(resolved)) {
        return (resolved as { data: T }).data;
      }
      return resolved as T;
    });
  };
  const state = usePromise<T>(innerFn as never, [key]);
  // For the non-paginated path: surface cached data / initialData as before.
  // For the paginated path: state.pagination is set and state.data is already the accumulated array.
  const data = state.pagination ? state.data : (state.data ?? options?.initialData);
  useEffect(() => { if (state.error) options?.onError?.(state.error); }, [state.error]); // eslint-disable-line react-hooks/exhaustive-deps
  return { ...state, data, pagination: state.pagination };
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

/* ============================================================ @raycast/utils parity helpers
 * Pure-JS ports (no host changes): icon generators return Image.ImageLike descriptors;
 * useLocalStorage/useFrecencySorting/withCache wrap the existing host LocalStorage RPC. */

/** Type of the `mutate` fn returned by Raycast's data hooks. Type-only — used for prop annotations. */
export type MutatePromise<T, U = undefined> = (
  asyncUpdate?: Promise<U>,
  options?: {
    optimisticUpdate?: (data: T) => T;
    rollbackOnError?: boolean | ((data: T) => T);
    shouldRevalidateAfter?: boolean;
  },
) => Promise<U>;

export interface FaviconOptions { fallback?: string; size?: number; mask?: string }
/** Image.ImageLike descriptor resolving a site's favicon (via Google's public S2 endpoint). */
export function getFavicon(
  url: string,
  options: FaviconOptions = {},
): { source: string; fallback?: string; mask?: string } {
  const size = options.size ?? 64;
  let domain = url;
  try {
    domain = new URL(url.includes("://") ? url : `https://${url}`).hostname;
  } catch {
    /* keep the raw value */
  }
  return {
    source: `https://www.google.com/s2/favicons?sz=${size}&domain=${encodeURIComponent(domain)}`,
    fallback: options.fallback,
    mask: options.mask,
  };
}

const AVATAR_COLORS = ["#EB5757", "#F2994A", "#F2C94C", "#27AE60", "#2F80ED", "#9B51E0", "#56CCF2", "#BB6BD9"];
function hashStr(s: string): number {
  let h = 0;
  for (const ch of s) h = (h * 31 + ch.charCodeAt(0)) | 0;
  return Math.abs(h);
}
/** Image.ImageLike for a generated initials avatar (colored circle + initials), as a data: SVG URL. */
export function getAvatarIcon(
  name: string,
  options: { background?: string; gradient?: boolean } = {},
): { source: string; mask?: string } {
  const initials = (name.trim().split(/\s+/).map((w) => w[0]).slice(0, 2).join("") || "?").toUpperCase();
  const bg = options.background ?? AVATAR_COLORS[hashStr(name) % AVATAR_COLORS.length];
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128"><rect width="128" height="128" fill="${bg}"/><text x="64" y="64" font-family="-apple-system,Helvetica,sans-serif" font-size="56" fill="#fff" text-anchor="middle" dominant-baseline="central">${initials}</text></svg>`;
  return { source: `data:image/svg+xml;base64,${Buffer.from(svg).toString("base64")}`, mask: "circle" };
}

/** Image.ImageLike of a circular progress ring (progress 0..1), as a data: SVG URL. */
export function getProgressIcon(
  progress: number,
  color = "#FF6363",
  options: { background?: string; backgroundOpacity?: number } = {},
): { source: string } {
  const p = Math.max(0, Math.min(1, progress));
  const r = 45;
  const circ = 2 * Math.PI * r;
  const dash = circ * p;
  const bg = options.background ?? "#000000";
  const bgOp = options.backgroundOpacity ?? 0.1;
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="100" height="100"><circle cx="50" cy="50" r="${r}" fill="none" stroke="${bg}" stroke-opacity="${bgOp}" stroke-width="10"/><circle cx="50" cy="50" r="${r}" fill="none" stroke="${color}" stroke-width="10" stroke-dasharray="${dash} ${circ}" stroke-linecap="round" transform="rotate(-90 50 50)"/></svg>`;
  return { source: `data:image/svg+xml;base64,${Buffer.from(svg).toString("base64")}` };
}

/** Hook over the host LocalStorage RPC: `{ value, setValue, removeValue, isLoading }`, JSON-(de)serialized. */
export function useLocalStorage<T>(key: string, initialValue?: T) {
  const api = useRef<typeof import("@invoke/api") | undefined>(undefined);
  const state = usePromise<T | undefined>(async () => {
    const a = (api.current ??= await import("@invoke/api"));
    const raw = await a.LocalStorage.getItem<string>(key);
    return raw == null ? initialValue : (JSON.parse(raw) as T);
  }, [key]);
  const setValue = useCallback(
    async (value: T) => {
      const a = (api.current ??= await import("@invoke/api"));
      await a.LocalStorage.setItem(key, JSON.stringify(value));
      state.revalidate();
    },
    [key], // eslint-disable-line react-hooks/exhaustive-deps
  );
  const removeValue = useCallback(
    async () => {
      const a = (api.current ??= await import("@invoke/api"));
      await a.LocalStorage.removeItem(key);
      state.revalidate();
    },
    [key], // eslint-disable-line react-hooks/exhaustive-deps
  );
  return { value: state.data, setValue, removeValue, isLoading: state.isLoading };
}

export interface FrecencySortingOptions<T> {
  namespace?: string;
  key?: (item: T) => string;
  sortUnvisited?: (a: T, b: T) => number;
}
/** Sort `data` by frecency (frequency × recency); rankings persist per-item in LocalStorage. */
export function useFrecencySorting<T>(
  data: T[] = [],
  options: FrecencySortingOptions<T> = {},
): { data: T[]; visitItem: (item: T) => Promise<void>; resetRanking: (item: T) => Promise<void> } {
  const keyOf = options.key ?? ((item: T) => String((item as { id?: unknown }).id ?? JSON.stringify(item)));
  const storageKey = `frecency-${options.namespace ?? "default"}`;
  type Entry = { lastVisited: number; visitCount: number };
  const { value, setValue } = useLocalStorage<Record<string, Entry>>(storageKey, {});
  const table = value ?? {};
  const score = (entry?: Entry): number => {
    if (!entry) return 0;
    const ageDays = (Date.now() - entry.lastVisited) / 86_400_000;
    return entry.visitCount * (1 / (1 + ageDays));
  };
  const sorted = [...data].sort((a, b) => {
    const diff = score(table[keyOf(b)]) - score(table[keyOf(a)]);
    return diff !== 0 ? diff : options.sortUnvisited ? options.sortUnvisited(a, b) : 0;
  });
  const visitItem = useCallback(
    async (item: T) => {
      const k = keyOf(item);
      await setValue({ ...table, [k]: { lastVisited: Date.now(), visitCount: (table[k]?.visitCount ?? 0) + 1 } });
    },
    [table], // eslint-disable-line react-hooks/exhaustive-deps
  );
  const resetRanking = useCallback(
    async (item: T) => {
      const next = { ...table };
      delete next[keyOf(item)];
      await setValue(next);
    },
    [table], // eslint-disable-line react-hooks/exhaustive-deps
  );
  return { data: sorted, visitItem, resetRanking };
}

/** Wrap an async fn so its result is cached in LocalStorage (with optional maxAge). Adds `.clearCache()`. */
export function withCache<A extends unknown[], T>(
  fn: (...args: A) => Promise<T>,
  options: { maxAge?: number; validate?: (data: T) => boolean } = {},
): ((...args: A) => Promise<T>) & { clearCache: () => Promise<void> } {
  const ns = "withCache:";
  const wrapped = (async (...args: A): Promise<T> => {
    const a = await import("@invoke/api");
    const cacheKey = ns + JSON.stringify(args);
    const raw = await a.LocalStorage.getItem<string>(cacheKey);
    if (raw) {
      try {
        const { value, expiresAt } = JSON.parse(raw) as { value: T; expiresAt: number };
        if ((!expiresAt || Date.now() < expiresAt) && (!options.validate || options.validate(value))) return value;
      } catch {
        /* corrupt entry — recompute */
      }
    }
    const value = await fn(...args);
    await a.LocalStorage.setItem(
      cacheKey,
      JSON.stringify({ value, expiresAt: options.maxAge ? Date.now() + options.maxAge : 0 }),
    );
    return value;
  }) as ((...args: A) => Promise<T>) & { clearCache: () => Promise<void> };
  wrapped.clearCache = async () => {
    const a = await import("@invoke/api");
    const all = await a.LocalStorage.allItems<Record<string, unknown>>();
    await Promise.all(
      Object.keys(all).filter((k) => k.startsWith(ns)).map((k) => a.LocalStorage.removeItem(k)),
    );
  };
  return wrapped;
}

/** Build a Raycast deeplink string (synchronous, pure). */
export function createDeeplink(opts: {
  type?: string;
  command?: string;
  extensionName?: string;
  ownerOrAuthorName?: string;
  arguments?: Record<string, unknown>;
  context?: Record<string, unknown>;
  fallbackText?: string;
}): string {
  const protocol = "raycast://";
  if (opts.type === "script-command") return `${protocol}script-commands/${opts.command ?? ""}`;
  const params = new URLSearchParams();
  if (opts.arguments) params.set("arguments", JSON.stringify(opts.arguments));
  if (opts.context) params.set("context", JSON.stringify(opts.context));
  if (opts.fallbackText) params.set("fallbackText", opts.fallbackText);
  const qs = params.toString();
  return `${protocol}extensions/${opts.ownerOrAuthorName ?? ""}/${opts.extensionName ?? ""}/${opts.command ?? ""}${qs ? `?${qs}` : ""}`;
}

/** Windows-only PowerShell runner — not available on macOS. Stub so imports survive module load. */
export async function runPowerShellScript(_script: string, _options?: unknown): Promise<string> {
  throw new Error("@invoke/utils: runPowerShellScript is Windows-only and not available on macOS");
}

export interface UseAIOptions {
  creativity?: number | string;
  model?: string;
  /** Skip until true (default true). */
  execute?: boolean;
  stream?: boolean;
  onData?: (data: string) => void;
  onError?: (error: Error) => void;
}
/** Raycast's useAI — runs an AI completion for `prompt`, exposing { data, isLoading, error, revalidate }.
 *  Backed by the host's Anthropic client via AI.ask (full result; streaming lands later). */
export function useAI(prompt: string, options: UseAIOptions = {}): AsyncState<string> & { data: string } {
  const execute = options.execute === undefined ? true : options.execute;
  const state = usePromise<string>(async () => {
    if (!execute) return "";
    const api = await import("@invoke/api");
    return api.AI.ask(prompt, { model: options.model, creativity: options.creativity });
  }, [prompt, execute]);
  useEffect(() => { if (state.error) options.onError?.(state.error); }, [state.error]); // eslint-disable-line react-hooks/exhaustive-deps
  useEffect(() => { if (state.data) options.onData?.(state.data); }, [state.data]); // eslint-disable-line react-hooks/exhaustive-deps
  return { ...state, data: state.data ?? "" };
}

/* ============================================================ OAuth helpers (@raycast/utils parity)
 * Convenience wrappers over @invoke/api's OAuth.PKCEClient: a service that runs the full
 * request→authorize→token-exchange→store sequence (with named provider presets), and a
 * withAccessToken HOC that authorizes before a command runs and exposes the token via getAccessToken. */
export interface OnAuthorizeParams { token: string; type: "oauth"; idToken?: string; scope?: string }
export interface OAuthServiceOptions {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  client: any; // OAuth.PKCEClient instance
  clientId: string;
  scope: string;
  authorizeUrl: string;
  tokenUrl: string;
  refreshTokenUrl?: string;
  extraParameters?: Record<string, string>;
  bodyEncoding?: "url-encoded" | "json";
  onAuthorize?: (params: OnAuthorizeParams) => void;
  personalAccessToken?: string;
}

async function exchangeToken(url: string, body: Record<string, string>, encoding: "url-encoded" | "json"): Promise<Record<string, unknown>> {
  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": encoding === "json" ? "application/json" : "application/x-www-form-urlencoded", Accept: "application/json" },
    body: encoding === "json" ? JSON.stringify(body) : new URLSearchParams(body).toString(),
  });
  if (!res.ok) throw new Error(`Token exchange failed: ${res.status} ${res.statusText}`);
  return (await res.json()) as Record<string, unknown>;
}

export class OAuthService {
  constructor(public options: OAuthServiceOptions) {}

  /** Returns a valid access token: a personal token if given, a cached non-expired token, else runs the
   *  full PKCE flow (authorize in the browser → exchange code → store tokens). */
  async authorize(): Promise<string> {
    if (this.options.personalAccessToken) return this.options.personalAccessToken;
    const client = this.options.client;
    const existing = await client.getTokens();
    if (existing?.accessToken && !existing.isExpired()) return existing.accessToken;
    // Refresh if we have a refresh token and a refresh endpoint.
    if (existing?.refreshToken && this.options.refreshTokenUrl) {
      try {
        const refreshed = await exchangeToken(this.options.refreshTokenUrl, {
          client_id: this.options.clientId, grant_type: "refresh_token", refresh_token: existing.refreshToken,
        }, this.options.bodyEncoding ?? "url-encoded");
        await client.setTokens({ refresh_token: existing.refreshToken, ...refreshed });
        const t = await client.getTokens();
        if (t?.accessToken) { this.options.onAuthorize?.({ token: t.accessToken, type: "oauth" }); return t.accessToken; }
      } catch { /* fall through to a fresh authorize */ }
    }
    if (!this.options.clientId) {
      // No client_id and no PAT: the extension relies on a hosted OAuth proxy (e.g. Raycast's) that
      // Invoke doesn't run. Fail with a clear, actionable message instead of opening an empty authorize
      // URL. Most such extensions accept a personal access token in preferences — point the user there.
      throw new Error("This extension needs a Personal Access Token — set it in Settings → Extensions (interactive OAuth isn't available without a client ID).");
    }
    const req = await client.authorizationRequest({
      endpoint: this.options.authorizeUrl, clientId: this.options.clientId, scope: this.options.scope,
      extraParameters: this.options.extraParameters,
    });
    const authResp = await client.authorize(req);
    if (!authResp || !authResp.authorizationCode) {
      throw new Error("Authorization was cancelled or did not complete.");
    }
    const authorizationCode = authResp.authorizationCode;
    const tokenResp = await exchangeToken(this.options.tokenUrl, {
      client_id: this.options.clientId, code: authorizationCode, code_verifier: req.codeVerifier,
      grant_type: "authorization_code", redirect_uri: req.redirectURI,
    }, this.options.bodyEncoding ?? "url-encoded");
    await client.setTokens(tokenResp);
    const token = String(tokenResp.access_token ?? "");
    this.options.onAuthorize?.({ token, type: "oauth" });
    return token;
  }

  /* Provider presets (real provider OAuth endpoints; only the URLs/scopes are config). */
  static github(o: { clientId: string; scope: string; personalAccessToken?: string; onAuthorize?: (p: OnAuthorizeParams) => void }) {
    return makeService(o, "GitHub", "https://github.com/login/oauth/authorize", "https://github.com/login/oauth/access_token");
  }
  static google(o: { clientId: string; scope: string; authorizeUrl?: string; tokenUrl?: string; personalAccessToken?: string; onAuthorize?: (p: OnAuthorizeParams) => void }) {
    return makeService(o, "Google", o.authorizeUrl ?? "https://accounts.google.com/o/oauth2/v2/auth", o.tokenUrl ?? "https://oauth2.googleapis.com/token");
  }
  static slack(o: { clientId: string; scope: string; personalAccessToken?: string; onAuthorize?: (p: OnAuthorizeParams) => void }) {
    return makeService(o, "Slack", "https://slack.com/oauth/v2/authorize", "https://slack.com/api/oauth.v2.access");
  }
  static linear(o: { clientId: string; scope: string; personalAccessToken?: string; onAuthorize?: (p: OnAuthorizeParams) => void }) {
    return makeService(o, "Linear", "https://linear.app/oauth/authorize", "https://api.linear.app/oauth/token");
  }
  static asana(o: { clientId: string; scope: string; personalAccessToken?: string; onAuthorize?: (p: OnAuthorizeParams) => void }) {
    return makeService(o, "Asana", "https://app.asana.com/-/oauth_authorize", "https://app.asana.com/-/oauth_token");
  }
  static jira(o: { clientId: string; scope: string; authorizeUrl?: string; tokenUrl?: string; personalAccessToken?: string; onAuthorize?: (p: OnAuthorizeParams) => void }) {
    return makeService(o, "Jira", o.authorizeUrl ?? "https://auth.atlassian.com/authorize", o.tokenUrl ?? "https://auth.atlassian.com/oauth/token");
  }
}

function makeService(
  o: { clientId: string; scope: string; personalAccessToken?: string; extraParameters?: Record<string, string>; onAuthorize?: (p: OnAuthorizeParams) => void },
  providerName: string, authorizeUrl: string, tokenUrl: string,
): OAuthService {
  // Lazily build a PKCEClient from @invoke/api (avoids a hard import cycle at module load).
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const apiP = import("@invoke/api") as Promise<any>;
  // The client is needed synchronously by authorize(); resolve it there instead.
  const lazyClient = {
    _c: undefined as unknown,
    async _get() { if (!this._c) { const api = await apiP; this._c = new api.OAuth.PKCEClient({ redirectMethod: "appURI", providerName }); } return this._c; },
    authorizationRequest(a: unknown) { return this._get().then((c: any) => c.authorizationRequest(a)); }, // eslint-disable-line @typescript-eslint/no-explicit-any
    authorize(a: unknown) { return this._get().then((c: any) => c.authorize(a)); }, // eslint-disable-line @typescript-eslint/no-explicit-any
    setTokens(a: unknown) { return this._get().then((c: any) => c.setTokens(a)); }, // eslint-disable-line @typescript-eslint/no-explicit-any
    getTokens() { return this._get().then((c: any) => c.getTokens()); }, // eslint-disable-line @typescript-eslint/no-explicit-any
    removeTokens() { return this._get().then((c: any) => c.removeTokens()); }, // eslint-disable-line @typescript-eslint/no-explicit-any
  };
  return new OAuthService({ client: lazyClient, clientId: o.clientId, scope: o.scope, authorizeUrl, tokenUrl, extraParameters: o.extraParameters, personalAccessToken: o.personalAccessToken, onAuthorize: o.onAuthorize });
}

let _accessToken: { token: string; type: "oauth" | "personal"; idToken?: string } | undefined;
/** The access token of the current withAccessToken-wrapped command. Throws if called outside one. */
export function getAccessToken(): { token: string; type: "oauth" | "personal"; idToken?: string } {
  if (!_accessToken) throw new Error("getAccessToken must be used inside a withAccessToken-wrapped command");
  return _accessToken;
}

export type WithAccessTokenComponentOrFn<T = unknown> = ((props: T) => ReactNode) | (() => Promise<void>);

/** HOC: authorize via the OAuthService (or a raw authorize fn) before running the wrapped command,
 *  storing the token for getAccessToken(). View components show a loading state until authorized. */
export function withAccessToken<T extends Record<string, unknown>>(
  options: OAuthService | { authorize: () => Promise<string>; personalAccessToken?: string; onAuthorize?: (p: OnAuthorizeParams) => void },
) {
  const authorize = () => (options as OAuthService).authorize();
  const pat = (options as { personalAccessToken?: string }).personalAccessToken;
  return (fnOrComponent: WithAccessTokenComponentOrFn<T>): WithAccessTokenComponentOrFn<T> => {
    // No-view command: a plain async function — authorize, then run it.
    if (fnOrComponent.length === 0 && !isLikelyComponent(fnOrComponent)) {
      return (async () => {
        const token = pat ?? (await authorize());
        _accessToken = { token, type: pat ? "personal" : "oauth" };
        await (fnOrComponent as () => Promise<void>)();
      }) as WithAccessTokenComponentOrFn<T>;
    }
    // View command: a component — render nothing until authorized, then render it with the token set.
    return ((props: T) => {
      const [ready, setReady] = useState<boolean>(!!_accessToken);
      useEffect(() => {
        let active = true;
        (async () => {
          try {
            if (!_accessToken) {
              const token = pat ?? (await authorize());
              _accessToken = { token, type: pat ? "personal" : "oauth" };
            }
            if (active) setReady(true);
          } catch (e) {
            // Authorize failed (e.g. no client id / cancelled): surface it instead of a permanent blank.
            await showFailureToast(e, { title: "Authorization failed" });
          }
        })();
        return () => { active = false; };
      }, []);
      if (!ready) return null;
      // Render the wrapped component as a CHILD element (createElement), NOT a direct function call.
      // A direct call inlines the child's hooks into this wrapper, so when `ready` flips false→true the
      // wrapper's hook count changes → "Rendered more hooks than during the previous render". As a child
      // element it has its own hook scope.
      return createElement(fnOrComponent as ComponentType<T>, props);
    }) as WithAccessTokenComponentOrFn<T>;
  };
}
// Heuristic: a React component's name is capitalized; a plain command fn usually isn't. Used only to
// disambiguate the zero-arg case (both no-view command fns and zero-prop components take no args).
function isLikelyComponent(fn: unknown): boolean {
  return typeof fn === "function" && /^[A-Z]/.test((fn as { name?: string }).name ?? "");
}

/** Incremental top-level-array JSON parser — emits complete elements as text chunks arrive.
 *  Pure/dependency-free; the basis for true progressive streaming in useStreamJSON.
 *  `push(chunk)` returns newly-completed top-level elements; `flush()` handles end-of-stream. */
export function createArrayStreamParser(): { push(chunk: string): unknown[]; flush(): unknown[] } {
  let buf = "";
  let cursor = 0;        // scan position in buf
  let opened = false;    // seen the top-level '['
  let closed = false;
  let depth = 0;         // nesting INSIDE the array (0 = directly in the array)
  let inStr = false, esc = false;
  let elemStart = -1;    // index in buf where the current element began, or -1 between elements

  function scan(): unknown[] {
    const out: unknown[] = [];
    while (cursor < buf.length) {
      const c = buf[cursor];
      if (!opened) { if (c === "[") { opened = true; } cursor++; continue; }
      if (closed) { cursor++; continue; }
      if (inStr) {
        if (esc) esc = false;
        else if (c === "\\") esc = true;
        else if (c === '"') inStr = false;
        cursor++; continue;
      }
      if (c === '"') { if (elemStart === -1) elemStart = cursor; inStr = true; cursor++; continue; }
      if (c === "{" || c === "[") { if (elemStart === -1) elemStart = cursor; depth++; cursor++; continue; }
      if (c === "}" || c === "]") {
        if (depth > 0) { depth--; cursor++; continue; }
        // depth 0 and a closing char → must be the array's ']'
        if (elemStart !== -1) { out.push(JSON.parse(buf.slice(elemStart, cursor))); elemStart = -1; }
        closed = true; cursor++; continue;
      }
      if (c === "," && depth === 0) {
        if (elemStart !== -1) { out.push(JSON.parse(buf.slice(elemStart, cursor))); elemStart = -1; }
        cursor++; continue;
      }
      if (elemStart === -1 && !/\s/.test(c)) elemStart = cursor; // element begins at first non-ws
      cursor++;
    }
    // bound memory: drop consumed prefix when between elements (elemStart === -1)
    if (elemStart === -1 && cursor > 0) { buf = buf.slice(cursor); cursor = 0; }
    else if (elemStart > 0) { buf = buf.slice(elemStart); cursor -= elemStart; elemStart = 0; }
    return out;
  }
  return {
    push(chunk: string) { buf += chunk; return scan(); },
    flush() { return scan(); },
  };
}

/** Raycast's useStreamJSON — streams a large JSON array from a URL/file.
 *  When no `dataPath` is set and the response body is a readable stream, uses
 *  `createArrayStreamParser` for memory-incremental parsing (no full-body buffer).
 *  Falls back to whole-parse when `dataPath` is set, `res.body` is absent, or the
 *  streaming parse throws (e.g. non-array top-level JSON). */
export interface UseStreamJSONOptions<T> {
  initialData?: T[];
  filter?: (item: T) => boolean;
  transform?: (item: unknown) => T;
  dataPath?: string; // a key in the response object holding the array
  execute?: boolean;
  onError?: (e: Error) => void;
}

/** Apply the same transform-then-filter pipeline used in the whole-parse path. */
function applyPipeline<T>(raw: unknown[], options: UseStreamJSONOptions<T>): T[] {
  let arr = raw as unknown[];
  if (options.transform) arr = arr.map(options.transform);
  let out = arr as T[];
  if (options.filter) out = out.filter(options.filter);
  return out;
}

export function useStreamJSON<T = unknown>(url: string, options: UseStreamJSONOptions<T> = {}): AsyncState<T[]> & { data: T[] } {
  const execute = options.execute === undefined ? true : options.execute;
  const state = usePromise<T[]>(async () => {
    if (!execute) return options.initialData ?? [];
    const res = await fetch(url);
    if (!res.ok) throw new Error(`${res.status} ${res.statusText}`);

    // --- Streaming path: only when no dataPath + body is a readable stream ---
    if (!options.dataPath && res.body) {
      try {
        const parser = createArrayStreamParser();
        const decoder = new TextDecoder();
        const reader = (res.body as ReadableStream<Uint8Array>).getReader();
        const accumulated: unknown[] = [];
        // eslint-disable-next-line no-constant-condition
        while (true) {
          const { done, value } = await reader.read();
          if (done) break;
          const chunk = decoder.decode(value, { stream: true });
          const elements = parser.push(chunk);
          accumulated.push(...elements);
        }
        // flush handles any trailing content after the last chunk
        const tail = parser.flush();
        accumulated.push(...tail);
        return applyPipeline(accumulated, options);
      } catch {
        // Streaming parse failed (e.g. non-array top-level) — fall through to whole-parse.
        // Re-fetch is needed since we consumed the body; fall through re-issues the request.
      }
    }

    // --- Whole-parse fallback (dataPath set, no res.body, or streaming parse error) ---
    // If we consumed the body above in the streaming path and it threw, we need a fresh response.
    const freshRes = res.bodyUsed ? await fetch(url) : res;
    let json: unknown = await freshRes.json();
    if (options.dataPath && json && typeof json === "object") json = (json as Record<string, unknown>)[options.dataPath];
    return applyPipeline(Array.isArray(json) ? json : [], options);
  }, [url, execute]);
  useEffect(() => { if (state.error) options.onError?.(state.error); }, [state.error]); // eslint-disable-line react-hooks/exhaustive-deps
  return { ...state, data: state.data ?? options.initialData ?? [] };
}
