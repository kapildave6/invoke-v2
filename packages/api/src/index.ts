/**
 * @invoke/api — the extension SDK (PLAN.md §5).
 *
 * Components are thin: each returns a React element with a lowercase *host tag*
 * (e.g. "list", "list-item", "action") that the reconciler (@invoke/reconciler)
 * knows how to emit as a mutation. Element-valued props (`actions`, `detail`,
 * `searchBarAccessory`) are LIFTED into children so the host sees them as nested
 * instances — this mirrors how Raycast treats those slots.
 *
 * This is API-SHAPE compatible with @raycast/api; the `@raycast/api` compat shim
 * (packages/compat-raycast) re-exports these under the original import names so
 * existing extensions port mechanically (PLAN.md §5.0).
 *
 * Platform APIs (Clipboard, environment, showToast, …) below are typed stubs that
 * route over the host RPC channel; in production the native host fulfils them.
 */
import { createElement, type ReactNode, type ReactElement } from "react";

/* ------------------------------------------------------------------ host tags */
const T = {
  List: "list",
  ListSection: "list-section",
  ListItem: "list-item",
  ListItemDetail: "list-item-detail",
  ListDropdown: "list-dropdown",
  EmptyView: "empty-view",
  Grid: "grid",
  GridSection: "grid-section",
  GridItem: "grid-item",
  Detail: "detail",
  Metadata: "metadata",
  MetadataLabel: "metadata-label",
  Form: "form",
  FormTextField: "form-textfield",
  FormTextArea: "form-textarea",
  FormCheckbox: "form-checkbox",
  FormDropdown: "form-dropdown",
  ActionPanel: "action-panel",
  ActionPanelSection: "action-panel-section",
  Action: "action",
  MenuBarExtra: "menubar-extra",
  MenuBarItem: "menubar-item",
} as const;

/** Build a host element, lifting element-valued slot props into children. */
function host(tag: string, slots: string[] = []) {
  return function HostComponent(props: Record<string, unknown> = {}): ReactElement {
    const { children, ...rest } = props as { children?: ReactNode } & Record<string, unknown>;
    const lifted: ReactNode[] = [];
    for (const name of slots) {
      const v = rest[name];
      if (v != null) {
        lifted.push(v as ReactNode);
        delete rest[name];
      }
    }
    const kids: ReactNode[] = [
      ...lifted,
      ...(Array.isArray(children) ? children : children != null ? [children] : []),
    ];
    return createElement(tag, rest, ...kids);
  };
}

/* ------------------------------------------------------------------ types */
export interface Accessory {
  text?: string;
  tag?: string | { value: string; color?: string };
  icon?: string;
  tooltip?: string;
  date?: string;
}
export interface CommonActionProps {
  title?: string;
  icon?: string;
  shortcut?: { modifiers: string[]; key: string };
  onAction?: () => void;
}

/* ------------------------------------------------------------------ List */
type ListType = ReturnType<typeof host> & {
  Section: ReturnType<typeof host>;
  Item: ReturnType<typeof host> & { Detail: ReturnType<typeof host> };
  Dropdown: ReturnType<typeof host>;
  EmptyView: ReturnType<typeof host>;
};
export const List = host(T.List, ["searchBarAccessory", "actions"]) as ListType;
List.Section = host(T.ListSection);
const ListItem = host(T.ListItem, ["actions", "detail"]) as ReturnType<typeof host> & {
  Detail: ReturnType<typeof host>;
};
ListItem.Detail = host(T.ListItemDetail, ["metadata"]);
List.Item = ListItem;
List.Dropdown = host(T.ListDropdown);
List.EmptyView = host(T.EmptyView, ["actions"]);

/* ------------------------------------------------------------------ Grid */
type GridType = ReturnType<typeof host> & {
  Section: ReturnType<typeof host>;
  Item: ReturnType<typeof host>;
  Dropdown: ReturnType<typeof host>;
  EmptyView: ReturnType<typeof host>;
};
export const Grid = host(T.Grid, ["searchBarAccessory", "actions"]) as GridType;
Grid.Section = host(T.GridSection);
Grid.Item = host(T.GridItem, ["actions"]);
Grid.Dropdown = host(T.ListDropdown);
Grid.EmptyView = host(T.EmptyView, ["actions"]);

/* ------------------------------------------------------------------ Detail */
type DetailType = ReturnType<typeof host> & {
  Metadata: ReturnType<typeof host> & { Label: ReturnType<typeof host> };
};
export const Detail = host(T.Detail, ["actions", "metadata"]) as DetailType;
const Metadata = host(T.Metadata) as ReturnType<typeof host> & { Label: ReturnType<typeof host> };
Metadata.Label = host(T.MetadataLabel);
Detail.Metadata = Metadata;

/* ------------------------------------------------------------------ Form */
type FormType = ReturnType<typeof host> & {
  TextField: ReturnType<typeof host>;
  TextArea: ReturnType<typeof host>;
  Checkbox: ReturnType<typeof host>;
  Dropdown: ReturnType<typeof host>;
};
export const Form = host(T.Form, ["actions"]) as FormType;
Form.TextField = host(T.FormTextField);
Form.TextArea = host(T.FormTextArea);
Form.Checkbox = host(T.FormCheckbox);
Form.Dropdown = host(T.FormDropdown);

/* ------------------------------------------------------------------ Actions */
type ActionType = ((props: CommonActionProps) => ReactElement) & {
  CopyToClipboard: (props: { content: string } & CommonActionProps) => ReactElement;
  Paste: (props: { content: string } & CommonActionProps) => ReactElement;
  OpenInBrowser: (props: { url: string } & CommonActionProps) => ReactElement;
  Push: (props: { target: ReactNode } & CommonActionProps) => ReactElement;
};
const makeAction = (variant: string) =>
  host(T.Action, ["target"]) as unknown as (p: Record<string, unknown>) => ReactElement;
function ActionImpl(props: CommonActionProps): ReactElement {
  return createElement(T.Action, { variant: "default", ...props });
}
export const Action = ActionImpl as ActionType;
Action.CopyToClipboard = (props) => createElement(T.Action, { variant: "copy", ...props });
Action.Paste = (props) => createElement(T.Action, { variant: "paste", ...props });
Action.OpenInBrowser = (props) => createElement(T.Action, { variant: "open-in-browser", ...props });
Action.Push = (props) => {
  const { target, ...rest } = props;
  return createElement(T.Action, { variant: "push", ...rest }, target);
};

type ActionPanelType = ReturnType<typeof host> & { Section: ReturnType<typeof host> };
export const ActionPanel = host(T.ActionPanel) as ActionPanelType;
ActionPanel.Section = host(T.ActionPanelSection);

/* ------------------------------------------------------------------ MenuBarExtra */
type MenuBarType = ReturnType<typeof host> & { Item: ReturnType<typeof host> };
export const MenuBarExtra = host(T.MenuBarExtra) as MenuBarType;
MenuBarExtra.Item = host(T.MenuBarItem, ["onAction"]);

/* ------------------------------------------------------------------ enums */
export const Icon = {
  Circle: "circle",
  Star: "star",
  Clipboard: "clipboard",
  Globe: "globe",
  Window: "window",
  Calendar: "calendar",
  MagnifyingGlass: "magnifying-glass",
} as const;

export const Color = {
  Blue: "blue",
  Green: "green",
  Magenta: "magenta",
  Orange: "orange",
  Purple: "purple",
  Red: "red",
  Yellow: "yellow",
  PrimaryText: "primary-text",
  SecondaryText: "secondary-text",
} as const;

export const Toast = {
  Style: { Success: "success", Failure: "failure", Animated: "animated" } as const,
};

export const LaunchType = { UserInitiated: "userInitiated", Background: "background" } as const;

/* ----------------------------------------------------- host RPC bridge (stubs) */
type RpcSender = (method: string, params: unknown) => Promise<unknown>;
let _rpc: RpcSender | null = null;
/** Wired up by the runtime child (runtime/node-host) so APIs can reach the host. */
export function __setHostBridge(send: RpcSender): void {
  _rpc = send;
}
async function rpc(method: string, params: unknown): Promise<unknown> {
  if (!_rpc) throw new Error(`@invoke/api: ${method} can only run inside the Invoke runtime`);
  return _rpc(method, params);
}

export const Clipboard = {
  copy: (content: string, opts?: { concealed?: boolean; transient?: boolean }) =>
    rpc("clipboard.copy", { content, ...opts }) as Promise<void>,
  paste: (content: string) => rpc("clipboard.paste", { content }) as Promise<void>,
  readText: () => rpc("clipboard.readText", {}) as Promise<string | undefined>,
};

export async function showToast(opts: { style: string; title: string; message?: string }): Promise<void> {
  await rpc("toast.show", opts);
}
export async function showHUD(title: string): Promise<void> {
  await rpc("hud.show", { title });
}
export async function closeMainWindow(opts?: { clearRootSearch?: boolean }): Promise<void> {
  await rpc("window.close", opts ?? {});
}

/** Open a URL or file path with the default app (or a specific one). */
export async function open(target: string, application?: string): Promise<void> {
  await rpc("open", { target, application });
}

/** Per-extension key/value store (host-fulfilled). Mirrors @raycast/api LocalStorage. */
export const LocalStorage = {
  getItem: <T = string>(key: string): Promise<T | undefined> =>
    rpc("localStorage.getItem", { key }) as Promise<T | undefined>,
  setItem: (key: string, value: string | number | boolean): Promise<void> =>
    rpc("localStorage.setItem", { key, value }) as Promise<void>,
  removeItem: (key: string): Promise<void> => rpc("localStorage.removeItem", { key }) as Promise<void>,
  clear: (): Promise<void> => rpc("localStorage.clear", {}) as Promise<void>,
  allItems: <T = Record<string, unknown>>(): Promise<T> => rpc("localStorage.allItems", {}) as Promise<T>,
};

export const environment = {
  appearance: "dark" as "dark" | "light",
  launchType: LaunchType.UserInitiated as string,
  commandName: process.env.INVOKE_COMMAND ?? "",
};

export function getPreferenceValues<T = Record<string, unknown>>(): T {
  try {
    return JSON.parse(process.env.INVOKE_PREFERENCES ?? "{}") as T;
  } catch {
    return {} as T;
  }
}

export type { ReactNode };
