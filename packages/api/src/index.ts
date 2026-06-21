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

/* ----------------------------------------------------- navigation (render-on-push)
 * Targets are NEVER rendered eagerly (eagerly mounting every row's push target recurses and runs
 * mount effects in the background — e.g. apple-notes firing a getNoteBody AppleScript per row just
 * from searching). Instead a push renders the target ON DEMAND as a new navigation frame: the runtime
 * child mounts it as a fresh reconciler root and streams it, the host stacks it, and Esc pops. The
 * runtime wires the controller via __setNavController (same process-global pattern as __setHostBridge),
 * so both useNavigation().push/pop and Action.Push share one render-on-push path. */
type NavController = { push: (view: ReactNode) => void; pop: () => void };
const NAV_KEY = "__invokeNav__";
/** Wired up by the runtime child (runtime/node-host) so navigation reaches the frame stack. */
export function __setNavController(c: NavController): void {
  (globalThis as Record<string, unknown>)[NAV_KEY] = c;
}
function navController(): NavController | undefined {
  return (globalThis as Record<string, unknown>)[NAV_KEY] as NavController | undefined;
}

/* ------------------------------------------------------------------ host tags */
const T = {
  List: "list",
  ListSection: "list-section",
  ListItem: "list-item",
  ListItemDetail: "list-item-detail",
  ListDropdown: "list-dropdown",
  ListDropdownItem: "list-dropdown-item",
  ListDropdownSection: "list-dropdown-section",
  EmptyView: "empty-view",
  Grid: "grid",
  GridSection: "grid-section",
  GridItem: "grid-item",
  Detail: "detail",
  Metadata: "metadata",
  MetadataLabel: "metadata-label",
  MetadataTagList: "metadata-taglist",
  MetadataTagListItem: "metadata-taglist-item",
  MetadataSeparator: "metadata-separator",
  MetadataLink: "metadata-link",
  Form: "form",
  FormTextField: "form-textfield",
  FormTextArea: "form-textarea",
  FormCheckbox: "form-checkbox",
  FormDescription: "form-description",
  FormSeparator: "form-separator",
  FormDropdown: "form-dropdown",
  FormDropdownItem: "form-dropdown-item",
  FormDropdownSection: "form-dropdown-section",
  FormPassword: "form-password",
  FormDatePicker: "form-datepicker",
  ActionPanel: "action-panel",
  ActionPanelSection: "action-panel-section",
  ActionPanelSubmenu: "action-panel-submenu",
  Action: "action",
  MenuBarExtra: "menubar-extra",
  MenuBarItem: "menubar-item",
  MenuBarSection: "menubar-section",
  MenuBarSubmenu: "menubar-submenu",
  MenuBarSeparator: "menubar-separator",
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
    // pagination.onLoadMore is a nested function; serializeProps only converts TOP-LEVEL functions to
    // handlers, so hoist it (and the scalars) to top-level props. Only List/Grid pass `pagination`.
    if (rest.pagination && typeof rest.pagination === "object") {
      const p = rest.pagination as { pageSize?: number; hasMore?: boolean; onLoadMore?: () => void };
      if (typeof p.onLoadMore === "function") rest.onLoadMore = p.onLoadMore;
      rest.paginationHasMore = !!p.hasMore;
      rest.paginationPageSize = p.pageSize;
      delete rest.pagination;
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
  style?: "regular" | "destructive";
  onAction?: () => void;
}

/* ------------------------------------------------------------------ List */
type DropdownType = ReturnType<typeof host> & {
  Item: ReturnType<typeof host>;
  Section: ReturnType<typeof host>;
};
type ListItemDetailType = ReturnType<typeof host> & { Metadata: MetadataType };
type ListType = ReturnType<typeof host> & {
  Section: ReturnType<typeof host>;
  Item: ReturnType<typeof host> & { Detail: ListItemDetailType };
  Dropdown: DropdownType;
  EmptyView: ReturnType<typeof host>;
};
export const List = host(T.List, ["searchBarAccessory", "actions"]) as ListType;
List.Section = host(T.ListSection);
const ListItem = host(T.ListItem, ["actions", "detail"]) as ReturnType<typeof host> & {
  Detail: ListItemDetailType;
};
ListItem.Detail = host(T.ListItemDetail, ["metadata"]) as ListItemDetailType;
// List.Item.Detail.Metadata is the SAME namespace as Detail.Metadata (Label/TagList/Separator/Link).
// Assigned after Metadata is defined below (extensions read List.Item.Detail.Metadata.Label at render;
// an undefined namespace throws and the whole command renders blank).
List.Item = ListItem;
// The search-bar Dropdown accessory has Item/Section children (Raycast). Without these defined,
// an extension rendering <List.Dropdown.Item> renders <undefined> → "Element type is invalid".
const ListDropdown = host(T.ListDropdown) as DropdownType;
ListDropdown.Item = host(T.ListDropdownItem);
ListDropdown.Section = host(T.ListDropdownSection);
List.Dropdown = ListDropdown;
List.EmptyView = host(T.EmptyView, ["actions"]);

/* ------------------------------------------------------------------ Grid */
type GridType = ReturnType<typeof host> & {
  Section: ReturnType<typeof host>;
  Item: ReturnType<typeof host>;
  Dropdown: DropdownType;
  EmptyView: ReturnType<typeof host>;
  ItemSize: { Small: "small"; Medium: "medium"; Large: "large" };
  Inset: { Small: "small"; Medium: "medium"; Large: "large" };
  Fit: { Contain: "contain"; Fill: "fill" };
};
export const Grid = host(T.Grid, ["searchBarAccessory", "actions"]) as GridType;
Grid.Section = host(T.GridSection);
Grid.Item = host(T.GridItem, ["actions"]);
Grid.Dropdown = ListDropdown; // Raycast: Grid.Dropdown === List.Dropdown
Grid.EmptyView = host(T.EmptyView, ["actions"]);
// Grid enums — extensions read e.g. Grid.ItemSize.Large at render; a missing enum throws and the
// whole command renders blank. Values mirror Raycast's string constants.
Grid.ItemSize = { Small: "small", Medium: "medium", Large: "large" } as const;
Grid.Inset = { Small: "small", Medium: "medium", Large: "large" } as const;
Grid.Fit = { Contain: "contain", Fill: "fill" } as const;

/* ------------------------------------------------------------------ Detail */
type MetadataType = ReturnType<typeof host> & {
  Label: ReturnType<typeof host>;
  TagList: ReturnType<typeof host> & { Item: ReturnType<typeof host> };
  Separator: ReturnType<typeof host>;
  Link: ReturnType<typeof host>;
};
type DetailType = ReturnType<typeof host> & { Metadata: MetadataType };
export const Detail = host(T.Detail, ["actions", "metadata"]) as DetailType;
const Metadata = host(T.Metadata) as MetadataType;
Metadata.Label = host(T.MetadataLabel);
const TagList = host(T.MetadataTagList) as ReturnType<typeof host> & { Item: ReturnType<typeof host> };
TagList.Item = host(T.MetadataTagListItem, ["onAction"]);
Metadata.TagList = TagList;
Metadata.Separator = host(T.MetadataSeparator);
Metadata.Link = host(T.MetadataLink);
Detail.Metadata = Metadata;
ListItem.Detail.Metadata = Metadata; // List.Item.Detail.Metadata === Detail.Metadata (Raycast)

/* ------------------------------------------------------------------ Form */
type DatePickerProps = Record<string, unknown> & { onChange?: (d: Date | null) => void };
type DatePickerFn = ((props: DatePickerProps) => ReactElement) & {
  Type: { Date: string; DateTime: string };
};
type FormType = ReturnType<typeof host> & {
  TextField: ReturnType<typeof host>;
  TextArea: ReturnType<typeof host>;
  Checkbox: ReturnType<typeof host>;
  Description: ReturnType<typeof host>;
  Separator: ReturnType<typeof host>;
  PasswordField: ReturnType<typeof host>;
  DatePicker: DatePickerFn;
  FilePicker: ReturnType<typeof host>;
  LinkAccessory: ReturnType<typeof host>;
  TagPicker: ReturnType<typeof host> & { Item: ReturnType<typeof host> };
  Dropdown: ReturnType<typeof host> & { Item: ReturnType<typeof host>; Section: ReturnType<typeof host> };
  DropdownItem: ReturnType<typeof host>;
};
export const Form = host(T.Form, ["actions"]) as FormType;
Form.TextField = host(T.FormTextField);
Form.TextArea = host(T.FormTextArea);
Form.Checkbox = host(T.FormCheckbox);
// A form's static text and divider (Raycast). Without these defined, a form using <Form.Description>
// or <Form.Separator> renders <undefined> → "Element type is invalid" and the whole view fails.
Form.Description = host(T.FormDescription);
Form.Separator = host(T.FormSeparator);
Form.PasswordField = host(T.FormPassword);
Form.DatePicker = ((props: DatePickerProps) =>
  createElement(T.FormDatePicker, {
    ...props,
    onChange: props.onChange ? (v: unknown) => props.onChange!(v ? new Date(String(v)) : null) : undefined,
  })) as unknown as typeof Form.DatePicker;
// Extensions read Form.DatePicker.Type.Date / .DateTime at render — a missing enum throws and the whole
// form renders blank. Define it (the control still renders as a text field for now).
(Form.DatePicker as DatePickerFn).Type = { Date: "date", DateTime: "date-time" };
const Dropdown = host(T.FormDropdown) as FormType["Dropdown"];
Dropdown.Item = host(T.FormDropdownItem);
Dropdown.Section = host(T.FormDropdownSection);
Form.Dropdown = Dropdown;
// Some extensions use the flat <Form.DropdownItem> instead of <Form.Dropdown.Item>; alias it so they
// render an option instead of undefined.
Form.DropdownItem = host(T.FormDropdownItem);
// No native file picker yet — degrade to a path text field (the value is a path string). Avoids the
// render crash for the ~180 extensions that use <Form.FilePicker>.
Form.FilePicker = host(T.FormTextField);
// LinkAccessory is a small inline accessory on a form field — render as inert description text.
Form.LinkAccessory = host(T.FormDescription);
// TagPicker is multi-select; degrade to a (single-select) dropdown so its <TagPicker.Item> children
// still render as options instead of throwing.
const TagPicker = host(T.FormDropdown) as FormType["TagPicker"];
TagPicker.Item = host(T.FormDropdownItem);
Form.TagPicker = TagPicker;

/* ------------------------------------------------------------------ Actions */
type ActionType = ((props: CommonActionProps) => ReactElement) & {
  CopyToClipboard: (props: { content: string } & CommonActionProps) => ReactElement;
  Paste: (props: { content: string } & CommonActionProps) => ReactElement;
  OpenInBrowser: (props: { url: string } & CommonActionProps) => ReactElement;
  Open: (props: { target: string; application?: string } & CommonActionProps) => ReactElement;
  Push: (props: { target: ReactNode } & CommonActionProps) => ReactElement;
  SubmitForm: (props: { onSubmit: (values: Record<string, unknown>) => void } & CommonActionProps) => ReactElement;
  ShowInFinder: (props: { path: string } & CommonActionProps) => ReactElement;
  Trash: (props: { paths: string | string[] } & CommonActionProps) => ReactElement;
  OpenWith: (props: { path: string } & CommonActionProps) => ReactElement;
  ToggleQuickLook: (props: { path?: string } & CommonActionProps) => ReactElement;
  CreateQuicklink: (props: Record<string, unknown> & CommonActionProps) => ReactElement;
  CreateSnippet: (props: Record<string, unknown> & CommonActionProps) => ReactElement;
  PickDate: (props: Record<string, unknown> & CommonActionProps) => ReactElement;
  Style: { Regular: "regular"; Destructive: "destructive" };
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
// Action.Open — open a file/URL/app target with the default (or a specific) application.
Action.Open = (props) => {
  const { target, application, onOpen, ...rest } = props as {
    target?: string; application?: string; onOpen?: () => void;
  } & Record<string, unknown>;
  return createElement(T.Action, { variant: "open", target, application, onAction: onOpen, ...rest });
};
Action.Push = (props) => {
  const { target, onPush, ...rest } = props as { target?: ReactNode; onPush?: () => void } & Record<string, unknown>;
  // Render-on-push: the action is a normal invokable action whose handler pushes the target as a new
  // navigation frame (rendered on demand). The target is never mounted until actually pushed.
  return createElement(T.Action, {
    variant: "push",
    ...rest,
    onAction: () => {
      navController()?.push(target as ReactNode);
      onPush?.();
    },
  });
};
Action.Style = { Regular: "regular", Destructive: "destructive" } as const;
// Form submit: the host gathers the field values and passes them to onAction (PLAN.md §5.3).
Action.SubmitForm = (props) => {
  const { onSubmit, ...rest } = props as { onSubmit?: (v: Record<string, unknown>) => void } & Record<string, unknown>;
  return createElement(T.Action, { variant: "submit-form", onAction: onSubmit, ...rest });
};
// Filesystem / item actions — thin wrappers over capabilities Invoke already has (finder.reveal, trash,
// open). The action's onAction handler runs back in the child and calls the matching host RPC.
Action.ShowInFinder = (props) => {
  const { path, onShow, ...rest } = props as { path?: string; onShow?: () => void } & Record<string, unknown>;
  return createElement(T.Action, { variant: "default", title: "Show in Finder", icon: "finder", ...rest,
    onAction: () => { void showInFinder(String(path ?? "")); onShow?.(); } });
};
Action.Trash = (props) => {
  const { paths, onTrashed, ...rest } = props as { paths?: string | string[]; onTrashed?: () => void } & Record<string, unknown>;
  return createElement(T.Action, { variant: "default", title: "Move to Trash", style: "destructive", ...rest,
    onAction: () => { void trash((paths ?? []) as string | string[]); onTrashed?.(); } });
};
Action.OpenWith = (props) => {
  // Host shows an app chooser (apps that can open the file) and opens with the pick.
  const { path, onOpen, ...rest } = props as { path?: string; onOpen?: () => void } & Record<string, unknown>;
  return createElement(T.Action, { variant: "default", title: "Open With", ...rest,
    onAction: () => { void rpc("open.with", { path: String(path ?? "") }); onOpen?.(); } });
};
Action.ToggleQuickLook = (props) => {
  // Real macOS Quick Look preview (host runs qlmanage -p).
  const { path, ...rest } = props as { path?: string } & Record<string, unknown>;
  return createElement(T.Action, { variant: "default", title: "Quick Look", icon: "eye", ...rest,
    onAction: () => { void rpc("quicklook.preview", { path: String(path ?? "") }); } });
};
Action.CreateQuicklink = (props) => {
  // Adds to Invoke's quicklink store (persisted).
  const { quicklink, onCreate, ...rest } = props as { quicklink?: { name?: string; link?: string }; onCreate?: () => void } & Record<string, unknown>;
  return createElement(T.Action, { variant: "default", title: "Create Quicklink", icon: "link", ...rest,
    onAction: () => { void rpc("quicklink.create", { name: quicklink?.name ?? "", link: quicklink?.link ?? "" }); onCreate?.(); } });
};
Action.CreateSnippet = (props) => {
  // Adds to Invoke's snippet store (persisted).
  const { snippet, onCreate, ...rest } = props as { snippet?: { name?: string; text?: string; keyword?: string }; onCreate?: () => void } & Record<string, unknown>;
  return createElement(T.Action, { variant: "default", title: "Create Snippet", ...rest,
    onAction: () => { void rpc("snippet.create", { name: snippet?.name ?? "", text: snippet?.text ?? "", keyword: snippet?.keyword ?? "" }); onCreate?.(); } });
};
Action.PickDate = (props) => {
  // Opens a native date picker (host) and calls onChange with the chosen Date (or null if cancelled).
  const { onChange, title, ...rest } = props as { onChange?: (d: Date | null) => void; title?: string } & Record<string, unknown>;
  return createElement(T.Action, { variant: "default", title: title ?? "Pick Date", icon: "calendar", ...rest,
    onAction: async () => {
      const iso = (await rpc("date.pick", { title: title ?? "Pick a date" })) as string | null;
      onChange?.(iso ? new Date(iso) : null);
    } });
};

type ActionPanelType = ReturnType<typeof host> & {
  Section: ReturnType<typeof host>;
  Submenu: ReturnType<typeof host>;
  Item: (props: CommonActionProps) => ReactElement;
};
export const ActionPanel = host(T.ActionPanel) as ActionPanelType;
ActionPanel.Section = host(T.ActionPanelSection);
ActionPanel.Submenu = host(T.ActionPanelSubmenu);
// Legacy Raycast API: <ActionPanel.Item> was the base action before <Action> (same props: title/icon/
// shortcut/onAction). Aliasing to Action fixes ~49 extensions whose actions otherwise render undefined
// (→ "Element type is invalid" → the whole view crashes).
ActionPanel.Item = Action;

/* ------------------------------------------------------------------ MenuBarExtra */
type MenuBarType = ReturnType<typeof host> & {
  Item: ReturnType<typeof host>;
  Section: ReturnType<typeof host>;
  Submenu: ReturnType<typeof host>;
  Separator: ReturnType<typeof host>;
};
export const MenuBarExtra = host(T.MenuBarExtra) as MenuBarType;
// NOTE: do NOT lift onAction into children — it's a function handler the reconciler serializes to a
// handler ref (a PROP). Lifting it makes React try to render the function as a child ("Functions are
// not valid as a React child") and the click handler is lost.
MenuBarExtra.Item = host(T.MenuBarItem);
MenuBarExtra.Section = host(T.MenuBarSection);   // a titled group of items
MenuBarExtra.Submenu = host(T.MenuBarSubmenu);   // a nested menu
MenuBarExtra.Separator = host(T.MenuBarSeparator);
// Action conveniences extensions use as menu items — all render as items with an onAction.
(MenuBarExtra as unknown as Record<string, unknown>).CopyToClipboard =
  (props: { content?: string; title?: string } & CommonActionProps) =>
    createElement(T.MenuBarItem, { ...props, onAction: () => { void Clipboard.copy(String(props.content ?? "")); } });
(MenuBarExtra as unknown as Record<string, unknown>).OpenInBrowser =
  (props: { url?: string; title?: string } & CommonActionProps) =>
    createElement(T.MenuBarItem, { title: props.title, ...props, onAction: () => { void open(String(props.url ?? "")); } });
// ConfigureCommand / LaunchCommand — render as plain items so the menu doesn't break; their actions
// (open prefs / launch another command) are best-effort.
(MenuBarExtra as unknown as Record<string, unknown>).ConfigureCommand =
  (props: CommonActionProps) => createElement(T.MenuBarItem, { title: "Configure Command", ...props });
(MenuBarExtra as unknown as Record<string, unknown>).LaunchCommand =
  (props: CommonActionProps) => createElement(T.MenuBarItem, props);

/* ------------------------------------------------------------------ enums */
export const Icon = {
  Circle: "circle",
  Star: "star",
  Clipboard: "clipboard",
  Globe: "globe",
  Window: "window",
  Calendar: "calendar",
  MagnifyingGlass: "magnifying-glass",
  // Additional names extensions reference (apple-notes et al.). Undefined values don't crash, but
  // defining them lets the renderer pick a real glyph instead of nothing.
  Hashtag: "hashtag",
  Link: "link",
  Lock: "lock",
  Person: "person",
  Plus: "plus",
  Trash: "trash",
  Eye: "eye",
  Gear: "gear",
  Stars: "stars",
  CheckCircle: "check-circle",
  ArrowClockwise: "arrow-clockwise",
  ArrowCounterClockwise: "arrow-counter-clockwise",
  ArrowNe: "arrow-ne",
  NewDocument: "new-document",
  Pin: "pin",
  Document: "document",
  Folder: "folder",
  Tag: "tag",
  // Names 1Password (and similar) reference for item categories etc.
  AppWindowGrid3x3: "app-window-grid-3x3",
  Car: "car",
  Code: "code",
  CodeBlock: "code-block",
  CreditCard: "credit-card",
  Crypto: "crypto",
  Envelope: "envelope",
  Fingerprint: "fingerprint",
  Gift: "gift",
  HardDrive: "hard-drive",
  Heartbeat: "heartbeat",
  Key: "key",
  Paperclip: "paperclip",
  Repeat: "repeat",
  Shield: "shield",
  StarCircle: "star-circle",
  Switch: "switch",
  Terminal: "terminal",
  Text: "text",
  Tree: "tree",
  Wallet: "wallet",
  Wifi: "wifi",
  WifiDisabled: "wifi-disabled",
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

/// Raycast's `Toast` is BOTH a namespace (`Toast.Style`) and a constructor (`new Toast({...})`) whose
/// instance auto-re-shows when you set `.style`/`.title`/`.message` (the Animated→Success pattern). Many
/// extensions (e.g. 8-ball) construct it directly, so it must be a class, not a plain object.
export class Toast {
  static Style = { Success: "success", Failure: "failure", Animated: "animated" } as const;
  private _style: string;
  private _title: string;
  private _message?: string;
  private _primaryAction?: unknown;
  private _secondaryAction?: unknown;
  private _pending = false;
  constructor(options: { style?: string; title: string; message?: string; primaryAction?: unknown; secondaryAction?: unknown }) {
    this._style = options.style ?? Toast.Style.Success;
    this._title = options.title;
    this._message = options.message;
    this._primaryAction = options.primaryAction;
    this._secondaryAction = options.secondaryAction;
  }
  private buildPayload(): Record<string, unknown> {
    const payload: Record<string, unknown> = { style: this._style, title: this._title, message: this._message };
    if (this._primaryAction || this._secondaryAction) {
      __clearToastCallbacks();
      if (this._primaryAction) payload.primaryAction = buildToastAction(this._primaryAction, this as unknown as ToastHandle);
      if (this._secondaryAction) payload.secondaryAction = buildToastAction(this._secondaryAction, this as unknown as ToastHandle);
    }
    return payload;
  }
  private reshow(): void {
    if (this._pending) return;
    this._pending = true;
    queueMicrotask(() => {
      this._pending = false;
      void rpc("toast.show", this.buildPayload()).catch(() => {});
    });
  }
  get style(): string { return this._style; }
  set style(v: string) { this._style = v; this.reshow(); }
  get title(): string { return this._title; }
  set title(v: string) { this._title = v; this.reshow(); }
  get message(): string | undefined { return this._message; }
  set message(v: string | undefined) { this._message = v; this.reshow(); }
  get primaryAction(): unknown { return this._primaryAction; }
  set primaryAction(v: unknown) { this._primaryAction = v; this.reshow(); }
  get secondaryAction(): unknown { return this._secondaryAction; }
  set secondaryAction(v: unknown) { this._secondaryAction = v; this.reshow(); }
  async show(): Promise<void> { await rpc("toast.show", this.buildPayload()); }
  async hide(): Promise<void> { await rpc("toast.show", { style: this._style, title: "", message: "" }); }
}

export const LaunchType = { UserInitiated: "userInitiated", Background: "background" } as const;
export const PopToRootType = { Immediate: "immediate", Suspended: "suspended", Default: "default" } as const;

/* ----------------------------------------------------- host RPC bridge (stubs) */
type RpcSender = (method: string, params: unknown) => Promise<unknown>;
// Store the bridge on globalThis, NOT a module-level variable. @invoke/api can be instantiated more
// than once in a child (the extension reaches it via the @raycast/api compat shim, whose "@invoke/api"
// can resolve to a different module URL than the one child.ts wired __setHostBridge onto). A per-module
// `_rpc` then leaves the extension's instance unwired — so e.g. showToast threw "can only run inside
// the Invoke runtime" even though executeSQL (a different instance) worked. A process-global is shared
// by every instance.
const BRIDGE_KEY = "__invokeHostRpc__";
/** Wired up by the runtime child (runtime/node-host) so APIs can reach the host. */
export function __setHostBridge(send: RpcSender): void {
  (globalThis as Record<string, unknown>)[BRIDGE_KEY] = send;
}
async function rpc(method: string, params: unknown): Promise<unknown> {
  const send = (globalThis as Record<string, unknown>)[BRIDGE_KEY] as RpcSender | undefined;
  if (!send) throw new Error(`@invoke/api: ${method} can only run inside the Invoke runtime`);
  return send(method, params);
}

/* ----- imperative host→child callback channel (toast actions; reusable). Lives on globalThis because
   @invoke/api may be instantiated more than once per child (see BRIDGE_KEY note). ----- */
const TOAST_CB_KEY = "__invokeToastCallbacks__";
const TOAST_CB_SEQ = "__invokeToastCbSeq__";
function toastCbMap(): Map<string, () => void> {
  const g = globalThis as Record<string, unknown>;
  let m = g[TOAST_CB_KEY] as Map<string, () => void> | undefined;
  if (!m) { m = new Map(); g[TOAST_CB_KEY] = m; }
  return m;
}
export function __clearToastCallbacks(): void { toastCbMap().clear(); }
export function __registerToastCallback(fn: () => void): string {
  const g = globalThis as Record<string, unknown>;
  const n = ((g[TOAST_CB_SEQ] as number | undefined) ?? 0) + 1;
  g[TOAST_CB_SEQ] = n;
  const id = `icb-${n}`;
  toastCbMap().set(id, fn);
  return id;
}
export function __invokeCallback(id: string, _args: unknown[]): void { toastCbMap().get(id)?.(); }

export const Clipboard = {
  copy: (content: string, opts?: { concealed?: boolean; transient?: boolean }) =>
    rpc("clipboard.copy", { content, ...opts }) as Promise<void>,
  paste: (content: string) => rpc("clipboard.paste", { content }) as Promise<void>,
  readText: () => rpc("clipboard.readText", {}) as Promise<string | undefined>,
  // Raycast's Clipboard.read() returns { text, file?, html? } from the general pasteboard.
  read: async (): Promise<{ text: string; file?: string; html?: string }> => {
    const r = (await rpc("clipboard.read", {})) as { text?: string; file?: string; html?: string } | undefined;
    return { text: r?.text ?? "", file: r?.file, html: r?.html };
  },
  clear: () => rpc("clipboard.clear", {}) as Promise<void>,
};

export interface ToastHandle { style: string; title: string; message?: string; hide: () => Promise<void>; show: () => Promise<void>; }

function buildToastAction(action: unknown, handle: ToastHandle): { title: string; __handler?: string; shortcut?: unknown } | undefined {
  if (!action || typeof action !== "object") return undefined;
  const a = action as { title?: string; onAction?: (t: ToastHandle) => void; shortcut?: unknown };
  const out: { title: string; __handler?: string; shortcut?: unknown } = { title: a.title ?? "" };
  if (typeof a.onAction === "function") out.__handler = __registerToastCallback(() => a.onAction!(handle));
  if (a.shortcut) out.shortcut = a.shortcut;
  return out;
}

/// Raycast's showToast has two call forms — the object form `showToast({ style, title, message })`
/// and the positional overload `showToast(style, title, message?)`. Support both, and return a mutable
/// handle so extensions can update `.style`/`.title`/`.message` (re-shown) or `.hide()` it.
export async function showToast(
  optsOrStyle: { style?: string; title: string; message?: string; primaryAction?: unknown; secondaryAction?: unknown } | string,
  title?: string,
  message?: string,
): Promise<ToastHandle> {
  const isObj = typeof optsOrStyle !== "string";
  const opts: { style?: string; title: string; message?: string; primaryAction?: unknown; secondaryAction?: unknown } = isObj
    ? { style: optsOrStyle.style ?? Toast.Style.Success, title: optsOrStyle.title, message: optsOrStyle.message, primaryAction: optsOrStyle.primaryAction, secondaryAction: optsOrStyle.secondaryAction }
    : { style: optsOrStyle, title: title ?? "", message };
  const primaryAction = opts.primaryAction;
  const secondaryAction = opts.secondaryAction;
  // Mutating .style/.title/.message must RE-SHOW the toast (Raycast's live-updating pattern:
  // an "Animated/Loading…" toast updated to Success/Failure). Setters were plain assignments before, so
  // the update was invisible. Debounce via microtask so setting all three fires a single re-show.
  const state = { style: opts.style ?? Toast.Style.Success, title: opts.title, message: opts.message as string | undefined };
  let pending = false;
  // Builds and sends the full toast payload (state + action handlers). Used by initial send,
  // reshow microtask, and handle.show() so action buttons are never lost on re-show.
  const sendToast = (): Promise<unknown> => {
    const payload: Record<string, unknown> = { ...state };
    if (primaryAction || secondaryAction) {
      __clearToastCallbacks();
      if (primaryAction) payload.primaryAction = buildToastAction(primaryAction, handle);
      if (secondaryAction) payload.secondaryAction = buildToastAction(secondaryAction, handle);
    }
    return rpc("toast.show", payload);
  };
  const handle = {
    get style() { return state.style; }, set style(v: string) { state.style = v; reshow(); },
    get title() { return state.title; }, set title(v: string) { state.title = v; reshow(); },
    get message() { return state.message; }, set message(v: string | undefined) { state.message = v; reshow(); },
    hide: async () => { await rpc("toast.show", { style: state.style, title: "", message: "" }); },
    show: async () => { await sendToast(); },
  } as ToastHandle;
  const reshow = (): void => {
    if (pending) return;
    pending = true;
    queueMicrotask(() => {
      pending = false;
      void sendToast().catch(() => {});
    });
  };
  await sendToast();
  return handle;
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

/** Run an AppleScript via the host (gated capability). Returns the script's string output.
 *  The first call triggers the macOS Automation permission prompt for the target app. */
export async function runAppleScript(source: string): Promise<string> {
  // Matches Raycast: resolves to the script's stdout on success, and THROWS on a script error (the host
  // rejects the RPC, which surfaces here as a rejected `await`). Extensions rely on the throw — e.g.
  // browser-tabs catches it to fall back from a WebKit to a Chromium activation script. On success we
  // coerce a null/undefined result (an empty script's output) to "" so callers can safely .split(...).
  const r = await rpc("runAppleScript", { source });
  return r == null ? "" : String(r);
}

/** Run a read-only SQL query against a local SQLite file via the host (gated capability). The host
 *  opens the file read-only, denies ATTACH / non-SELECT statements, and asks for per-extension consent
 *  on first use. Resolves to the result rows (each an object keyed by column name). */
export async function executeSQL<T = unknown>(databasePath: string, query: string): Promise<T[]> {
  return (await rpc("executeSQL", { db: databasePath, query })) as T[];
}

/** Per-extension key/value store (host-fulfilled). Mirrors @raycast/api LocalStorage. */
export const LocalStorage = {
  // Raycast returns `undefined` for a missing key; the host RPC returns JSON null → JS null. Coerce
  // null→undefined so callers that test `=== undefined` (and then skip JSON.parse) behave correctly —
  // otherwise a missing key yields null, JSON.parse(null) → null, and the caller derefs null.
  getItem: async <T = string>(key: string): Promise<T | undefined> => {
    const v = await rpc("localStorage.getItem", { key });
    return (v == null ? undefined : v) as T | undefined;
  },
  setItem: (key: string, value: string | number | boolean): Promise<void> =>
    rpc("localStorage.setItem", { key, value }) as Promise<void>,
  removeItem: (key: string): Promise<void> => rpc("localStorage.removeItem", { key }) as Promise<void>,
  clear: (): Promise<void> => rpc("localStorage.clear", {}) as Promise<void>,
  allItems: <T = Record<string, unknown>>(): Promise<T> => rpc("localStorage.allItems", {}) as Promise<T>,
};

export const environment = {
  appearance: "dark" as "dark" | "light",
  launchType: (process.env.INVOKE_LAUNCH_TYPE as string) || LaunchType.UserInitiated,
  commandName: process.env.INVOKE_COMMAND ?? "",
  commandMode: process.env.INVOKE_MODE ?? "view",
  // The extension's assets/ dir and a writable per-extension support dir (host-provided). Extensions
  // commonly reference these AT MODULE LOAD — e.g. join(environment.assetsPath, "img.png") — so they
  // must be real strings, never undefined, or the module throws and the command can't start.
  assetsPath: process.env.INVOKE_ASSETS_PATH ?? "",
  supportPath: process.env.INVOKE_SUPPORT_PATH ?? "",
  isDevelopment: false,
  raycastVersion: "1.103.6",
  textSize: "medium" as "medium" | "large",
  // Raycast gates some features (e.g. AI) on environment.canAccess(API); we don't expose those yet.
  canAccess: (_api: unknown): boolean => false,
  // Extension/owner identity — host sets these when known; "" until then. Used by createDeeplink.
  extensionName: process.env.INVOKE_EXTENSION ?? "",
  ownerOrAuthorName: process.env.INVOKE_OWNER ?? "",
};

export function getPreferenceValues<T = Record<string, unknown>>(): T {
  try {
    return JSON.parse(process.env.INVOKE_PREFERENCES ?? "{}") as T;
  } catch {
    return {} as T;
  }
}

/* --------------------------------------------- stubs for not-yet-implemented APIs (PLAN.md §5/§10)
 * Exported so an extension that merely IMPORTS these still LOADS (an unknown named ESM import would
 * otherwise fail the whole module at load time). They throw a clear error only if actually CALLED;
 * `invoke import` reports which of these an extension touches. */
function unsupported(name: string): never {
  throw new Error(`@invoke/api: ${name} is not supported in Invoke yet`);
}

/** Per-extension key/value cache. Raycast's Cache API is SYNCHRONOUS, so reads/writes hit an in-memory
 *  map; writes also fire-and-forget to the host's persisted store, and the constructor kicks off a
 *  best-effort warm load so values survive across launches. Memory-only if no host is present. */
export class Cache {
  private ns: string;
  private store = new Map<string, string>();
  constructor(options?: { namespace?: string; capacity?: number }) {
    this.ns = options?.namespace ?? "";
    void this.warm();
  }
  private hostKey(key: string): string { return `${this.ns}\u0000${key}`; }
  private async warm(): Promise<void> {
    try {
      const all = (await rpc("cache.allItems", {})) as Record<string, string> | undefined;
      const prefix = `${this.ns}\u0000`;
      for (const [k, v] of Object.entries(all ?? {})) {
        if (!k.startsWith(prefix)) continue;
        const bare = k.slice(prefix.length);
        if (!this.store.has(bare)) this.store.set(bare, v); // never clobber a fresh in-session write
      }
    } catch {
      /* no host / cache unavailable — stay memory-only */
    }
  }
  get(key: string): string | undefined { return this.store.get(key); }
  has(key: string): boolean { return this.store.has(key); }
  set(key: string, value: string): void {
    this.store.set(key, value);
    void rpc("cache.set", { key: this.hostKey(key), value }).catch(() => {});
  }
  remove(key: string): boolean {
    const had = this.store.delete(key);
    void rpc("cache.remove", { key: this.hostKey(key) }).catch(() => {});
    return had;
  }
  clear(): void {
    this.store.clear();
    void rpc("cache.clear", { namespace: this.ns }).catch(() => {});
  }
  /** Raycast's Cache.subscribe (reactive listeners). Not wired — returns a no-op unsubscribe. */
  subscribe(_subscriber?: (key: string | undefined, data: string | undefined) => void): () => void {
    return () => {};
  }
  get isEmpty(): boolean { return this.store.size === 0; }
}
/* AI-extension tools (manifest tools[]). `Tool` is mostly used in type position (Tool.Input/Output);
 * `Tool.Confirmation` is a value an interactive tool returns to request a confirm step. */
export const Tool = {
  /** Wrap a confirmation payload (Raycast: a tool returns this to ask the user before acting). Invoke
   *  doesn't gate on it yet, so it's an identity passthrough so the value/type resolves. */
  Confirmation: <T>(payload: T): T => payload,
};
export interface AIAskOptions { model?: string; creativity?: number | string; system?: string }
export const AI = {
  /** Single-prompt completion via the host's Anthropic client (Raycast's AI.ask). Resolves to the text. */
  ask: (prompt: string, opts?: AIAskOptions): Promise<string> =>
    rpc("ai.ask", { prompt, model: opts?.model, creativity: opts?.creativity, system: opts?.system }) as Promise<string>,
  // AI.Model.* — Raycast exposes named model constants; return the key so any access is a harmless string
  // (the host maps unknown models to its configured default), never an undefined-member crash.
  Model: new Proxy({} as Record<string, string>, { get: (_t, k) => String(k) }),
};
/* ----------------------------------------------------- OAuth (PKCE, host-driven)
 * The host owns the security-critical parts: PKCE verifier/challenge generation, opening the browser,
 * capturing the invoke://oauth-callback redirect, and storing tokens in the per-extension Keychain. The
 * SDK methods are thin RPC wrappers. Tokens never leave the device. */
export interface OAuthTokenResponse {
  access_token: string;
  refresh_token?: string;
  expires_in?: number;
  scope?: string;
  id_token?: string;
}
export interface OAuthTokenSet {
  accessToken: string;
  refreshToken?: string;
  idToken?: string;
  expiresIn?: number;
  scope?: string;
  updatedAt?: string;
  isExpired(): boolean;
}
export interface OAuthAuthorizationRequest {
  authorizationEndpoint: string;
  clientId: string;
  scope: string;
  redirectURI: string;
  codeChallenge: string;
  codeVerifier: string;
  state: string;
  toURL(): string;
}
export interface OAuthAuthorizationResponse { authorizationCode: string }

export const OAuth = {
  RedirectMethod: { Web: "web", App: "app", AppURI: "appURI" } as const,
  PKCEClient: class PKCEClient {
    private opts: { redirectMethod?: string; providerName?: string; providerId?: string; providerIcon?: unknown; description?: string };
    constructor(opts: { redirectMethod?: string; providerName?: string; providerId?: string; providerIcon?: unknown; description?: string }) {
      this.opts = opts ?? {};
    }
    private get provider(): string { return this.opts.providerId ?? this.opts.providerName ?? "default"; }

    async authorizationRequest(o: { endpoint: string; clientId: string; scope: string; extraParameters?: Record<string, string> }): Promise<OAuthAuthorizationRequest> {
      const r = (await rpc("oauth.authorizeRequest", {
        provider: this.provider, endpoint: o.endpoint, clientId: o.clientId, scope: o.scope, extraParameters: o.extraParameters,
      })) as Omit<OAuthAuthorizationRequest, "toURL">;
      return { ...r, toURL: () => buildAuthorizeURL(r) };
    }
    async authorize(request: OAuthAuthorizationRequest): Promise<OAuthAuthorizationResponse> {
      return (await rpc("oauth.authorize", { provider: this.provider, request })) as OAuthAuthorizationResponse;
    }
    async setTokens(tokens: OAuthTokenResponse | OAuthTokenSet): Promise<void> {
      await rpc("oauth.setTokens", { provider: this.provider, tokens });
    }
    async getTokens(): Promise<OAuthTokenSet | undefined> {
      const t = (await rpc("oauth.getTokens", { provider: this.provider })) as
        (Omit<OAuthTokenSet, "isExpired"> & { expiresAt?: number }) | undefined | null;
      if (!t || !t.accessToken) return undefined;
      // Reconstruct isExpired() from the host's stored absolute expiry (functions can't cross the wire).
      return { ...t, isExpired: () => (t.expiresAt ? Date.now() >= t.expiresAt : false) };
    }
    async removeTokens(): Promise<void> { await rpc("oauth.removeTokens", { provider: this.provider }); }
  },
};
function buildAuthorizeURL(r: { authorizationEndpoint: string; clientId: string; scope: string; redirectURI: string; codeChallenge: string; state: string }): string {
  const u = new URL(r.authorizationEndpoint);
  const p = u.searchParams;
  p.set("client_id", r.clientId);
  p.set("response_type", "code");
  p.set("redirect_uri", r.redirectURI);
  p.set("scope", r.scope);
  p.set("code_challenge", r.codeChallenge);
  p.set("code_challenge_method", "S256");
  p.set("state", r.state);
  return u.toString();
}
/** Back-compat alias: one extension imports `OAuthClient`. */
export const OAuthClient = OAuth;
/** A macOS application (Raycast's Application). */
export interface Application { name: string; path: string; bundleId?: string; localizedName?: string }
/** The highlighted text in the frontmost app (host-read via Accessibility; "" if none/unavailable). */
export async function getSelectedText(): Promise<string> { return (await rpc("selection.read", {})) as string; }
/** Installed apps, or (with a path/URL) the apps that can open it. */
export async function getApplications(path?: string): Promise<Application[]> { return (await rpc("app.list", { path })) as Application[]; }
/** The app that was frontmost when the command was invoked. */
export async function getFrontmostApplication(): Promise<Application> { return (await rpc("app.frontmost", {})) as Application; }
/** The default app that opens the file/URL at `path`. */
export async function getDefaultApplication(path: string): Promise<Application> { return (await rpc("app.default", { path })) as Application; }
/** Move one or more paths to the Trash (recoverable; host-gated per extension). */
export async function trash(paths: string | string[]): Promise<void> {
  await rpc("fs.trash", { paths: Array.isArray(paths) ? paths : [paths] });
}
/** Reveal and select a path in Finder. */
export async function showInFinder(path: string): Promise<void> { await rpc("finder.reveal", { path }); }
/** The items currently selected in the frontmost Finder window. */
export async function getSelectedFinderItems(): Promise<{ path: string }[]> {
  return (await rpc("finder.selection", {})) as { path: string }[];
}
/** Launch another command — a sibling in the same extension by `name`, or a command in another
 *  extension via `extensionName`. The host resolves the target, applies its preferences, and runs it
 *  (foreground for view commands, headless for no-view / `type: "background"`), passing `arguments`
 *  and `context` (the target reads them via LaunchProps.arguments / launchContext). */
export async function launchCommand(options: {
  name: string; type?: string; extensionName?: string; ownerOrAuthorName?: string;
  arguments?: Record<string, unknown>; context?: unknown; fallbackText?: string;
}): Promise<void> {
  await rpc("command.launch", {
    name: options.name,
    type: options.type ?? LaunchType.UserInitiated,
    extensionName: options.extensionName ?? null,
    arguments: options.arguments ?? {},
    context: options.context ?? {},
  });
}
/** Update the current command's root-list subtitle. Host wiring pending — no-op so callers don't break. */
export async function updateCommandMetadata(metadata: { subtitle?: string | null }): Promise<void> {
  await rpc("command.updateMetadata", { subtitle: metadata?.subtitle ?? null });
}
export interface BrowserExtensionTab {
  id: string;
  url: string;
  title: string;
  active: boolean;
  favicon?: string;
}
/** Best-effort HTML→Markdown (no DOM in the extension host). Handles the common block/inline tags;
 *  unknown tags collapse to their text. text/html formats stay exact — this only backs `markdown`. */
export function htmlToMarkdown(html: string): string {
  let s = html;
  s = s.replace(/<script[\s\S]*?<\/script>/gi, "").replace(/<style[\s\S]*?<\/style>/gi, "");
  s = s.replace(/<h([1-6])[^>]*>([\s\S]*?)<\/h\1>/gi, (_m, n, t) => `\n${"#".repeat(Number(n))} ${t.trim()}\n`);
  s = s.replace(/<(strong|b)[^>]*>([\s\S]*?)<\/\1>/gi, (_m, _t, t) => `**${t}**`);
  s = s.replace(/<(em|i)[^>]*>([\s\S]*?)<\/\1>/gi, (_m, _t, t) => `*${t}*`);
  s = s.replace(/<code[^>]*>([\s\S]*?)<\/code>/gi, (_m, t) => `\`${t}\``);
  s = s.replace(/<a[^>]*href=["']([^"']*)["'][^>]*>([\s\S]*?)<\/a>/gi, (_m, href, t) => `[${t.trim()}](${href})`);
  s = s.replace(/<li[^>]*>([\s\S]*?)<\/li>/gi, (_m, t) => `\n- ${t.trim()}`);
  s = s.replace(/<(p|div|section|article|br|tr|h[1-6])[^>]*>/gi, "\n");
  s = s.replace(/<[^>]+>/g, ""); // strip remaining tags
  s = s.replace(/&nbsp;/g, " ").replace(/&amp;/g, "&").replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&quot;/g, '"').replace(/&#39;/g, "'");
  return s.replace(/\n{3,}/g, "\n\n").replace(/[ \t]+\n/g, "\n").trim();
}
function tabFaviconURL(url: string): string | undefined {
  try { return `https://www.google.com/s2/favicons?sz=64&domain=${new URL(url).hostname}`; } catch { return undefined; }
}
export const BrowserExtension = {
  Tab: undefined as unknown, // present so `BrowserExtension.Tab` (a type reference) never throws at runtime
  async getTabs(): Promise<BrowserExtensionTab[]> {
    const tabs = (await rpc("browser.getTabs", {})) as BrowserExtensionTab[];
    return (tabs ?? []).map((t) => ({ ...t, favicon: t.favicon ?? tabFaviconURL(t.url) }));
  },
  async getContent(options?: { tabId?: string; format?: "html" | "text" | "markdown"; cssSelector?: string }): Promise<string> {
    const format = options?.format ?? "markdown";
    const hostFormat = format === "markdown" ? "html" : format; // host only does html/text
    const raw = (await rpc("browser.getContent", { tabId: options?.tabId, format: hostFormat, cssSelector: options?.cssSelector })) as string;
    return format === "markdown" ? htmlToMarkdown(raw ?? "") : (raw ?? "");
  },
};
export async function popToRoot(_opts?: unknown): Promise<void> { await closeMainWindow(); }
export async function openExtensionPreferences(): Promise<void> { await rpc("preferences.open", { scope: "extension" }); }
export async function openCommandPreferences(): Promise<void> { await rpc("preferences.open", { scope: "command" }); }
export async function confirmAlert(options: {
  title: string;
  message?: string;
  icon?: unknown;
  primaryAction?: { title?: string; style?: string; onAction?: () => void };
  dismissAction?: { title?: string; style?: string; onAction?: () => void };
  rememberUserChoice?: boolean;
}): Promise<boolean> {
  const confirmed = (await rpc("confirmAlert", {
    title: options?.title ?? "",
    message: options?.message,
    icon: typeof options?.icon === "string" ? options.icon : (options?.icon as { source?: string } | undefined)?.source,
    primaryTitle: options?.primaryAction?.title,
    primaryStyle: options?.primaryAction?.style,
    dismissTitle: options?.dismissAction?.title,
    dismissStyle: (options?.dismissAction as { style?: string } | undefined)?.style,
    rememberUserChoice: options?.rememberUserChoice ?? false,
  })) as boolean;
  // Raycast also invokes the action's onAction callback (many extensions wire the work there, not on
  // the boolean — e.g. a delete handler). Fire the matching one, then return the boolean too.
  if (confirmed) options?.primaryAction?.onAction?.();
  else options?.dismissAction?.onAction?.();
  return confirmed;
}
export function captureException(error: unknown): void {
  const e = error as { message?: string; stack?: string } | undefined;
  // Fire-and-forget diagnostic; must never throw (it's called from extensions' error paths).
  void rpc("captureException", { message: e?.message ?? String(error), stack: e?.stack }).catch(() => {});
}
/** Programmatic navigation. Backed by the runtime's render-on-push frame stack (__setNavController);
 *  push(view) mounts `view` as a new frame, pop() unwinds it. Falls back to no-ops outside the runtime. */
export function useNavigation(): { push: (view: ReactNode) => void; pop: () => void } {
  const nav = navController();
  return { push: (view) => nav?.push(view), pop: () => nav?.pop() };
}
export const Alert = { ActionStyle: { Default: "default", Destructive: "destructive", Cancel: "cancel" } as const };
// Keyboard.Shortcut.Common — Raycast's predefined shortcuts. Extensions read e.g.
// Keyboard.Shortcut.Common.Open, so this MUST be a populated object (a bare {} makes `.Common.Open`
// throw and takes the whole view down). Values mirror Raycast's defaults.
type Shortcut = { modifiers: string[]; key: string };
export const Keyboard = {
  Shortcut: {
    Common: {
      Copy: { modifiers: ["cmd", "shift"], key: "c" },
      CopyDeeplink: { modifiers: ["cmd", "shift"], key: "c" },
      CopyName: { modifiers: ["cmd", "shift"], key: "." },
      CopyPath: { modifiers: ["cmd", "shift"], key: "," },
      Duplicate: { modifiers: ["cmd"], key: "d" },
      Edit: { modifiers: ["cmd"], key: "e" },
      MoveDown: { modifiers: ["cmd", "shift"], key: "arrowDown" },
      MoveUp: { modifiers: ["cmd", "shift"], key: "arrowUp" },
      New: { modifiers: ["cmd"], key: "n" },
      Open: { modifiers: ["cmd"], key: "o" },
      OpenWith: { modifiers: ["cmd", "shift"], key: "o" },
      Pin: { modifiers: ["cmd", "shift"], key: "p" },
      Refresh: { modifiers: ["cmd"], key: "r" },
      Remove: { modifiers: ["ctrl"], key: "x" },
      RemoveAll: { modifiers: ["ctrl", "shift"], key: "x" },
      ToggleQuickLook: { modifiers: ["cmd"], key: "y" },
    } as Record<string, Shortcut>,
  } as Record<string, unknown>,
};
export const Image = { Mask: { Circle: "circle", RoundedRectangle: "roundedRectangle" } as const };

/* ------------------------------------------- legacy v1 @raycast/api aliases (compat)
 * Many older extensions import the pre-namespacing flat names. The modern forms already
 * exist above; these aliases keep those imports from failing at module load. Declared here
 * so every referenced symbol (Action, Toast, Image, LocalStorage, Clipboard, …) is defined. */
export const OpenInBrowserAction = Action.OpenInBrowser;
export const CopyToClipboardAction = Action.CopyToClipboard;
export const PasteAction = Action.Paste;
export const OpenAction = Action.Open;
export const PushAction = Action.Push;
export const SubmitFormAction = Action.SubmitForm;
// Action.OpenWith — open a file with a chosen app (degrades to Action.Open) + its v1 alias.
const openWith = (props: { path?: string; target?: string } & CommonActionProps): ReactElement =>
  Action.Open({ target: String(props.path ?? props.target ?? ""), ...props });
(Action as unknown as Record<string, unknown>).OpenWith = openWith;
export const OpenWithAction = openWith;
export const ToastStyle = Toast.Style;
export const ImageMask = Image.Mask;
export const getLocalStorageItem = LocalStorage.getItem;
export const setLocalStorageItem = LocalStorage.setItem;
export const removeLocalStorageItem = LocalStorage.removeItem;
export const allLocalStorageItems = LocalStorage.allItems;
export const clearLocalStorage = LocalStorage.clear;
export const copyTextToClipboard = Clipboard.copy;
export const pasteText = Clipboard.paste;
// v1 exposed resolved preferences as a module object; the modern API is getPreferenceValues().
export const preferences = getPreferenceValues();
// Trivial helper some v1 extensions import from the api package.
export function randomId(): string {
  return Math.random().toString(36).slice(2) + Date.now().toString(36);
}
// v1 imperative search reset — no imperative search handle yet, so a harmless no-op keeps the import alive.
export async function clearSearchBar(_options?: { forceScrollToTop?: boolean }): Promise<void> {}

// Raycast v1 imperative render(<Command/>) — the modern model renders the default export, so this is a
// compat no-op that keeps the import alive (v1 extensions calling it still load).
export function render(_element: ReactNode): void {}
// Some extensions import `fetch` from @raycast/api; it's just the platform fetch.
export const fetch = globalThis.fetch?.bind(globalThis);
// Window management (Raycast's WindowManagement) — not wired; methods throw only if called.
export const WindowManagement = {
  getActiveWindow: (): Promise<unknown> => unsupported("WindowManagement.getActiveWindow"),
  getWindowsOnActiveDesktop: (): Promise<unknown[]> => unsupported("WindowManagement.getWindowsOnActiveDesktop"),
  setWindowBounds: (_opts?: unknown): Promise<void> => unsupported("WindowManagement.setWindowBounds"),
  getDesktops: (): Promise<unknown[]> => unsupported("WindowManagement.getDesktops"),
};

export type { ReactNode };
