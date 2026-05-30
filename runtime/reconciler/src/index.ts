/**
 * @invoke/reconciler — PLAN.md §4.5, the linchpin.
 *
 * A custom host config on `react-reconciler` in MUTATION MODE. Instead of a DOM,
 * the "host" is a tree of lightweight instances; every commit emits the minimal
 * set of mutations (create/append/update/remove) straight from React's commit
 * phase. That stream is what we ship over IPC to the native host (PLAN.md §4.6),
 * which applies it to AppKit view models (in Node here, to a plain tree — §4.7).
 *
 * STABILITY DISCIPLINE (PLAN.md §4.5 / §9): react-reconciler's host-config surface
 * is NOT semver-stable. We therefore pin react + react-reconciler exactly and keep
 * the cast surface in this one file, so a bump is a single, reviewable diff. The
 * public contract extensions depend on is `@invoke/api`, never this module.
 *
 * NOTE: one surface per process — matches "process-per-extension" (PLAN.md §4.4),
 * so module-level singletons (pending buffer + handler registry) are correct here.
 */
import Reconciler from "react-reconciler";
import { ConcurrentRoot, DefaultEventPriority } from "react-reconciler/constants";
import type { ReactNode } from "react";
import { type Mutation, type NodeId, type SerializedProps, ROOT } from "@invoke/schema";

interface Instance {
  id: NodeId;
  type: string;
  props: Record<string, unknown>;
  children: Array<Instance | TextInstance>;
}
interface TextInstance {
  id: NodeId;
  text: string;
  isText: true;
}
interface Container {
  id: NodeId;
  children: Array<Instance | TextInstance>;
}

/* ---- per-process state (one surface per process) ---- */
let pending: Mutation[] = [];
let idSeq = 0;
let commitSeq = 0;
let currentUpdatePriority = 0; // NoEventPriority
let onCommit: ((commit: number, ops: Mutation[]) => void) | null = null;
const nextId = (): NodeId => ++idSeq;

/** Maps a live function prop to a wire-safe handle the host can call back. */
class HandlerRegistry {
  private byId = new Map<string, { fn: (...a: unknown[]) => unknown; prop: string; instance: NodeId }>();
  private seq = 0;

  register(fn: (...a: unknown[]) => unknown, prop: string, instance: NodeId): string {
    const id = `h${++this.seq}`;
    this.byId.set(id, { fn, prop, instance });
    return id;
  }
  clearInstance(instance: NodeId): void {
    for (const [id, e] of this.byId) if (e.instance === instance) this.byId.delete(id);
  }
  get(id: string): ((...a: unknown[]) => unknown) | undefined {
    return this.byId.get(id)?.fn;
  }
  /** Find the current handler id for a given prop name (used for onSearchTextChange). */
  findByProp(prop: string): string | undefined {
    for (const [id, e] of this.byId) if (e.prop === prop) return id;
    return undefined;
  }
}
const registry = new HandlerRegistry();

const isReactElement = (v: unknown): boolean =>
  typeof v === "object" && v !== null && "$$typeof" in (v as Record<string, unknown>);

function serializeProps(instance: NodeId, props: Record<string, unknown>): SerializedProps {
  registry.clearInstance(instance);
  const out: SerializedProps = {};
  for (const [k, v] of Object.entries(props)) {
    if (k === "children" || v === undefined) continue;
    if (typeof v === "function") {
      out[k] = { __handler: registry.register(v as (...a: unknown[]) => unknown, k, instance) };
    } else if (isReactElement(v)) {
      // Element-valued props should have been lifted to children by @invoke/api.
      continue;
    } else {
      out[k] = v;
    }
  }
  return out;
}

function flushCommit(): void {
  if (pending.length === 0) return;
  const ops = pending;
  pending = [];
  onCommit?.(++commitSeq, ops);
}

const hostConfig = {
  supportsMutation: true,
  supportsPersistence: false,
  supportsHydration: false,
  isPrimaryRenderer: true,
  noTimeout: -1 as const,
  supportsMicrotasks: true,
  scheduleMicrotask: queueMicrotask,
  scheduleTimeout: setTimeout,
  cancelTimeout: clearTimeout,

  getRootHostContext: () => ({}),
  getChildHostContext: (parent: unknown) => parent,
  getPublicInstance: (i: unknown) => i,
  prepareForCommit: () => null,
  resetAfterCommit: () => flushCommit(),
  shouldSetTextContent: () => false,
  // 0.31 split event priority into get/set/resolve (was getCurrentEventPriority).
  getCurrentEventPriority: () => DefaultEventPriority,
  setCurrentUpdatePriority: (p: number) => {
    currentUpdatePriority = p;
  },
  getCurrentUpdatePriority: () => currentUpdatePriority,
  resolveUpdatePriority: () => currentUpdatePriority || DefaultEventPriority,
  getInstanceFromNode: () => null,
  beforeActiveInstanceBlur: () => {},
  afterActiveInstanceBlur: () => {},
  prepareScopeUpdate: () => {},
  getInstanceFromScope: () => null,
  detachDeletedInstance: () => {},
  maySuspendCommit: () => false,
  // React 19 / reconciler 0.31 niceties (no-ops for us):
  resetFormInstance: () => {},
  requestPostPaintCallback: () => {},
  shouldAttemptEagerTransition: () => false,
  trackSchedulerEvent: () => {},
  resolveEventType: () => null,
  resolveEventTimeStamp: () => -1.1,

  clearContainer: (c: Container) => {
    c.children = [];
    pending.push({ op: "clearContainer" });
  },

  createInstance: (type: string, props: Record<string, unknown>): Instance => {
    const id = nextId();
    pending.push({ op: "createInstance", id, type, props: serializeProps(id, props) });
    return { id, type, props, children: [] };
  },
  createTextInstance: (text: string): TextInstance => {
    const id = nextId();
    pending.push({ op: "createText", id, text });
    return { id, text, isText: true };
  },

  appendInitialChild: (parent: Instance, child: Instance | TextInstance) => {
    parent.children.push(child);
    pending.push({ op: "appendChild", parent: parent.id, child: child.id });
  },
  finalizeInitialChildren: () => false,

  appendChild: (parent: Instance, child: Instance | TextInstance) => {
    parent.children.push(child);
    pending.push({ op: "appendChild", parent: parent.id, child: child.id });
  },
  appendChildToContainer: (c: Container, child: Instance | TextInstance) => {
    c.children.push(child);
    pending.push({ op: "appendChild", parent: ROOT, child: child.id });
  },
  insertBefore: (parent: Instance, child: Instance | TextInstance, before: Instance | TextInstance) => {
    pending.push({ op: "insertBefore", parent: parent.id, child: child.id, before: before.id });
  },
  insertInContainerBefore: (_c: Container, child: Instance | TextInstance, before: Instance | TextInstance) => {
    pending.push({ op: "insertBefore", parent: ROOT, child: child.id, before: before.id });
  },
  removeChild: (parent: Instance, child: Instance | TextInstance) => {
    pending.push({ op: "removeChild", parent: parent.id, child: child.id });
  },
  removeChildFromContainer: (_c: Container, child: Instance | TextInstance) => {
    pending.push({ op: "removeChild", parent: ROOT, child: child.id });
  },
  commitTextUpdate: (t: TextInstance, _old: string, next: string) => {
    pending.push({ op: "updateText", id: t.id, text: next });
  },
  commitUpdate: (instance: Instance, _type: string, _prev: Record<string, unknown>, next: Record<string, unknown>) => {
    instance.props = next;
    pending.push({ op: "updateProps", id: instance.id, props: serializeProps(instance.id, next) });
  },
};

// `any` is deliberate: @types/react-reconciler trails the runtime (createContainer
// arity, flushSyncFromReconciler) — the §4.5 drift, contained to this one binding.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const R: any = Reconciler(hostConfig as any);

export interface Surface {
  /** (Re)render the surface; emits a commit synchronously via the onCommit callback. */
  render(element: ReactNode): void;
  /** Invoke a handler the host received over the wire (e.g. an Action's onAction). */
  invokeHandler(handlerId: string, args: unknown[]): void;
  /** Resolve the current handler id bound to a prop (e.g. "onSearchTextChange"). */
  handlerForProp(prop: string): string | undefined;
  unmount(): void;
}

export interface SurfaceOptions {
  onCommit: (commit: number, ops: Mutation[]) => void;
}

export function createSurface(opts: SurfaceOptions): Surface {
  onCommit = opts.onCommit;
  const container: Container = { id: ROOT, children: [] };
  const root = R.createContainer(
    container,
    ConcurrentRoot,
    null,
    false,
    null,
    "invoke",
    (e: unknown) => console.error("[reconciler] uncaught", e),
    (e: unknown) => console.error("[reconciler] caught", e),
    (e: unknown) => console.error("[reconciler] recoverable", e),
    null,
  );

  // 0.31 renamed legacy `flushSync` → `flushSyncFromReconciler`; this single line
  // is the kind of one-spot churn the pinning discipline in §4.5 is designed to absorb.
  const flushSync: (fn: () => void) => void = R.flushSyncFromReconciler ?? R.flushSync;

  return {
    render(element) {
      flushSync(() => R.updateContainer(element, root, null, null));
    },
    invokeHandler(handlerId, args) {
      const fn = registry.get(handlerId);
      if (!fn) return;
      flushSync(() => fn(...args));
    },
    handlerForProp(prop) {
      return registry.findByProp(prop);
    },
    unmount() {
      flushSync(() => R.updateContainer(null, root, null, null));
    },
  };
}
