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
 * NAVIGATION (render-on-push): one process can host MULTIPLE mounted React roots —
 * one per navigation frame. The base command is frame 0 (container id ROOT); each
 * useNavigation().push(view) / Action.Push mounts `view` as a NEW root whose ops
 * stream tagged with that frame id, so lower frames stay mounted (state preserved)
 * and the host stacks the frames. Ops are tagged by the COMMITTING container, which
 * react-reconciler hands us (createInstance's rootContainer, prepareForCommit), so
 * even an async setState in a lower frame routes to the right frame.
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
  frame: NodeId; // which navigation frame this node belongs to (= its root container id)
}
interface TextInstance {
  id: NodeId;
  text: string;
  isText: true;
  frame: NodeId;
}
interface Container {
  id: NodeId; // also the frame id
  children: Array<Instance | TextInstance>;
}

/* ---- per-process state. One PROCESS per extension (PLAN.md §4.4), but possibly several mounted
 * frames (navigation roots) within it. Buffers/seqs are process-global; the handler registry and
 * every emitted op are tagged with the owning frame so frames stay isolated. ---- */
let pending: Mutation[] = [];
let idSeq = 0;
let commitSeq = 0;
let frameSeq = 0; // base frame is ROOT (0); pushed frames are 1, 2, …
let committingFrame: NodeId = ROOT; // the frame whose commit is currently being flushed
let currentUpdatePriority = 0; // NoEventPriority
let onCommit: ((commit: number, ops: Mutation[], frame: NodeId) => void) | null = null;
const nextId = (): NodeId => ++idSeq;

/** Maps a live function prop to a wire-safe handle the host can call back. Tagged by frame so a
 *  popped frame's handlers can be released wholesale and onSearchTextChange resolves to the live frame. */
class HandlerRegistry {
  private byId = new Map<string, { fn: (...a: unknown[]) => unknown; prop: string; instance: NodeId; frame: NodeId }>();
  private seq = 0;

  register(fn: (...a: unknown[]) => unknown, prop: string, instance: NodeId, frame: NodeId): string {
    const id = `h${++this.seq}`;
    this.byId.set(id, { fn, prop, instance, frame });
    return id;
  }
  clearInstance(instance: NodeId): void {
    for (const [id, e] of this.byId) if (e.instance === instance) this.byId.delete(id);
  }
  clearFrame(frame: NodeId): void {
    for (const [id, e] of this.byId) if (e.frame === frame) this.byId.delete(id);
  }
  get(id: string): ((...a: unknown[]) => unknown) | undefined {
    return this.byId.get(id)?.fn;
  }
  /** Find the current handler id for a prop name within a frame (used for onSearchTextChange). */
  findByProp(prop: string, frame: NodeId): string | undefined {
    for (const [id, e] of this.byId) if (e.prop === prop && e.frame === frame) return id;
    return undefined;
  }
}
const registry = new HandlerRegistry();

const isReactElement = (v: unknown): boolean =>
  typeof v === "object" && v !== null && "$$typeof" in (v as Record<string, unknown>);

function serializeProps(instance: NodeId, props: Record<string, unknown>, frame: NodeId): SerializedProps {
  registry.clearInstance(instance);
  const out: SerializedProps = {};
  for (const [k, v] of Object.entries(props)) {
    if (k === "children" || v === undefined) continue;
    if (typeof v === "function") {
      out[k] = { __handler: registry.register(v as (...a: unknown[]) => unknown, k, instance, frame) };
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
  onCommit?.(++commitSeq, ops, committingFrame);
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
  // prepareForCommit receives the committing container — pin the frame so this commit's ops (and any
  // render-phase createInstance ops already buffered for the same root) flush tagged with it.
  prepareForCommit: (container: Container) => {
    committingFrame = container.id;
    return null;
  },
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

  createInstance: (type: string, props: Record<string, unknown>, rootContainer: Container): Instance => {
    const id = nextId();
    const frame = rootContainer.id;
    pending.push({ op: "createInstance", id, type, props: serializeProps(id, props, frame) });
    return { id, type, props, children: [], frame };
  },
  createTextInstance: (text: string, rootContainer: Container): TextInstance => {
    const id = nextId();
    pending.push({ op: "createText", id, text });
    return { id, text, isText: true, frame: rootContainer.id };
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
  // Container-level ops use ROOT as the parent: every frame's host-side tree is independent with its
  // own ROOT, and the FRAME is carried by the mutations message envelope (committingFrame), not the
  // container node id. (Using c.id here pointed appends at a node that doesn't exist in frame >0's tree,
  // leaving pushed views empty.) c.id is still the frame id, used only to tag the commit.
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
    pending.push({ op: "updateProps", id: instance.id, props: serializeProps(instance.id, next, instance.frame) });
  },
};

// `any` is deliberate: @types/react-reconciler trails the runtime (createContainer
// arity, flushSyncFromReconciler) — the §4.5 drift, contained to this one binding.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const R: any = Reconciler(hostConfig as any);

export interface Surface {
  /** (Re)render the base frame (frame 0); emits a commit synchronously via the onCommit callback. */
  render(element: ReactNode): void;
  /** Mount `element` as a NEW navigation frame (render-on-push). Returns the new frame id. */
  pushFrame(element: ReactNode): NodeId;
  /** Unmount the top frame, releasing its handlers; the parent frame stays mounted. Returns the new
   *  active frame id (the parent), or ROOT if already at the base. */
  popFrame(): NodeId;
  /** The current (top) frame id. */
  activeFrame(): NodeId;
  /** Invoke a handler the host received over the wire (e.g. an Action's onAction). */
  invokeHandler(handlerId: string, args: unknown[]): void;
  /** Resolve the current handler id bound to a prop in the active frame (e.g. "onSearchTextChange"). */
  handlerForProp(prop: string): string | undefined;
  unmount(): void;
}

export interface SurfaceOptions {
  onCommit: (commit: number, ops: Mutation[], frame: NodeId) => void;
}

export function createSurface(opts: SurfaceOptions): Surface {
  onCommit = opts.onCommit;

  // 0.31 renamed legacy `flushSync` → `flushSyncFromReconciler`; this single line
  // is the kind of one-spot churn the pinning discipline in §4.5 is designed to absorb.
  const flushSync: (fn: () => void) => void = R.flushSyncFromReconciler ?? R.flushSync;

  interface Frame {
    id: NodeId;
    container: Container;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    root: any;
  }
  const newRoot = (container: Container) =>
    R.createContainer(
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

  // Stack of mounted frames; the base (frame 0) is created on first render.
  const frames: Frame[] = [];
  const makeFrame = (id: NodeId): Frame => {
    const container: Container = { id, children: [] };
    return { id, container, root: newRoot(container) };
  };

  return {
    render(element) {
      if (frames.length === 0) frames.push(makeFrame(ROOT));
      const base = frames[0];
      flushSync(() => R.updateContainer(element, base.root, null, null));
    },
    pushFrame(element) {
      const frame = makeFrame(++frameSeq);
      frames.push(frame);
      flushSync(() => R.updateContainer(element, frame.root, null, null));
      return frame.id;
    },
    popFrame() {
      if (frames.length <= 1) return frames[0]?.id ?? ROOT;
      const top = frames.pop()!;
      // Unmount the top root → emits clearContainer for its frame; then drop its handlers.
      committingFrame = top.id; // ensure the unmount's ops flush tagged with the popped frame
      flushSync(() => R.updateContainer(null, top.root, null, null));
      registry.clearFrame(top.id);
      return frames[frames.length - 1].id;
    },
    activeFrame() {
      return frames[frames.length - 1]?.id ?? ROOT;
    },
    invokeHandler(handlerId, args) {
      const fn = registry.get(handlerId);
      if (!fn) return;
      flushSync(() => fn(...args));
    },
    handlerForProp(prop) {
      return registry.findByProp(prop, frames[frames.length - 1]?.id ?? ROOT);
    },
    unmount() {
      while (frames.length) {
        const f = frames.pop()!;
        flushSync(() => R.updateContainer(null, f.root, null, null));
        registry.clearFrame(f.id);
      }
    },
  };
}
