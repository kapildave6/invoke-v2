/**
 * View-model tree — the host's side of the render-mutation stream (PLAN.md §4.5/§4.7).
 *
 * In production this lives in Swift and binds to AppKit widgets. Here it's a plain
 * tree so we can prove the protocol end-to-end in Node and pretty-print the result.
 */
import type { Mutation, NodeId, SerializedProps } from "@invoke/schema";
import { ROOT } from "@invoke/schema";

export interface VNode {
  id: NodeId;
  type: string; // "" for text nodes, "#root" for the container
  text?: string;
  props: SerializedProps;
  children: VNode[];
}

export interface ViewTree {
  root: VNode;
  index: Map<NodeId, VNode>;
}

export function createViewTree(): ViewTree {
  const root: VNode = { id: ROOT, type: "#root", props: {}, children: [] };
  return { root, index: new Map([[ROOT, root]]) };
}

export function applyMutations(tree: ViewTree, ops: Mutation[]): void {
  for (const op of ops) {
    switch (op.op) {
      case "clearContainer":
        // Only detach the container's children — instances created this commit
        // still live in the index and are about to be (re)attached.
        tree.root.children = [];
        break;
      case "createInstance":
        tree.index.set(op.id, { id: op.id, type: op.type, props: op.props, children: [] });
        break;
      case "createText":
        tree.index.set(op.id, { id: op.id, type: "", text: op.text, props: {}, children: [] });
        break;
      case "appendChild": {
        const parent = tree.index.get(op.parent);
        const child = tree.index.get(op.child);
        if (parent && child) parent.children.push(child);
        break;
      }
      case "insertBefore": {
        const parent = tree.index.get(op.parent);
        const child = tree.index.get(op.child);
        const before = tree.index.get(op.before);
        if (parent && child) {
          const at = before ? parent.children.indexOf(before) : -1;
          if (at >= 0) parent.children.splice(at, 0, child);
          else parent.children.push(child);
        }
        break;
      }
      case "removeChild": {
        const parent = tree.index.get(op.parent);
        const child = tree.index.get(op.child);
        if (parent && child) parent.children = parent.children.filter((c) => c !== child);
        break;
      }
      case "updateProps": {
        const n = tree.index.get(op.id);
        if (n) n.props = op.props;
        break;
      }
      case "updateText": {
        const n = tree.index.get(op.id);
        if (n) n.text = op.text;
        break;
      }
    }
  }
}

/** Find the first node of `type` whose `props.title` matches (used by the demo). */
export function findNode(tree: ViewTree, type: string, title?: string): VNode | undefined {
  for (const n of tree.index.values()) {
    if (n.type === type && (title === undefined || n.props.title === title)) return n;
  }
  return undefined;
}

const LABEL_PROPS = ["title", "subtitle", "text", "placeholder", "searchBarPlaceholder", "markdown"];

export function renderTree(node: VNode, depth = 0): string {
  const pad = "  ".repeat(depth);
  let line: string;
  if (node.type === "#root") {
    line = `${pad}◆ surface`;
  } else if (node.type === "") {
    line = `${pad}"${node.text}"`;
  } else {
    const label = LABEL_PROPS.map((p) => node.props[p]).find((v) => typeof v === "string");
    const extra: string[] = [];
    if (Array.isArray(node.props.accessories)) {
      const tags = (node.props.accessories as Array<Record<string, unknown>>)
        .map((a) => a.tag ?? a.text)
        .filter(Boolean);
      if (tags.length) extra.push(`[${tags.join(", ")}]`);
    }
    if (node.props.onAction) extra.push("⏎");
    line = `${pad}${node.type}${label ? ` "${String(label).slice(0, 40)}"` : ""}${extra.length ? " " + extra.join(" ") : ""}`;
  }
  const childLines = node.children.map((c) => renderTree(c, depth + 1));
  return [line, ...childLines].join("\n");
}
