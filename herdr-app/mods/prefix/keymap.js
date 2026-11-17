const GROUPS = [
  {
    title: "Tabs",
    bindings: [
      { keys: ["c", "ctrl-c"], label: "New tab", run: "tab.new" },
      { keys: ["A", ","], label: "Rename tab", run: "tab.rename" },
      { keys: ["ctrl-a"], label: "Last tab", run: "tab.select", args: (_key, last) => last && { id: last } },
      { keys: ["&"], label: "Close tab", run: "tab.close" },
      { keys: ["n"], label: "Next tab", run: "tab.next" },
      { keys: ["p"], label: "Previous tab", run: "tab.prev" },
      { keys: ["<"], label: "Move tab left", run: "tab.move", args: { by: -1 } },
      { keys: [">"], label: "Move tab right", run: "tab.move", args: { by: 1 } },
      {
        keys: ["1", "2", "3", "4", "5", "6", "7", "8", "9"],
        show: "1-9",
        label: "Select tab",
        run: "tab.select",
        args: (key) => ({ index: Number(key) }),
      },
    ],
  },
  {
    title: "Panes",
    bindings: [
      { keys: ["v", "|", "\\"], label: "Split right", run: "pane.split", args: { direction: "right" } },
      { keys: ["s", "-", "_"], label: "Split down", run: "pane.split", args: { direction: "down" } },
      { keys: ["h", "ctrl-h"], label: "Pane left", run: "pane.go", args: { direction: "left" } },
      { keys: ["j", "ctrl-j"], label: "Pane down", run: "pane.go", args: { direction: "down" } },
      { keys: ["k"], label: "Pane up", run: "pane.go", args: { direction: "up" } },
      { keys: ["l"], label: "Pane right", run: "pane.go", args: { direction: "right" } },
      { keys: ["z"], label: "Zoom pane", run: "pane.zoom" },
      { keys: ["x"], label: "Close pane", run: "pane.close" },
    ],
  },
  {
    title: "Other",
    bindings: [
      { keys: ["ctrl-f"], label: "Pick a tab or space", run: "mod.open", args: { name: "picker" } },
      { keys: ["a"], label: "Send ctrl-a", send: "ctrl+a" },
    ],
  },
];

const BINDINGS = GROUPS.flatMap(({ bindings }) => bindings);

export function helpGroups() {
  return GROUPS.map(({ title, bindings }) => ({
    title,
    rows: bindings.map(({ keys, show, label }) => ({
      keys: show ?? keys.map((key) => key.replace(/^ctrl-/, "^")).join(" "),
      label,
    })),
  }));
}

export function rememberTab(history, { space, tab }, openSpaces) {
  const kept = Object.entries(history).filter(([id]) => openSpaces.includes(id));
  const seen = history[space];
  const entry = seen?.current === tab ? seen : { current: tab, last: seen?.current };
  return { ...Object.fromEntries(kept), [space]: entry };
}

export function lastTab(history, { space }, openTabs) {
  const last = history[space]?.last;
  return openTabs.includes(last) ? last : undefined;
}

export function actionFor(event, last) {
  const { control, alt, platform } = event.modifiers;
  const stroke = alt || platform ? undefined : control ? `ctrl-${event.key}` : event.key_char;
  const binding = BINDINGS.find(({ keys }) => keys.includes(stroke));
  if (!binding) return { close: true };
  if (binding.send) return { send: binding.send };
  const { args = {} } = binding;
  const resolved = typeof args === "function" ? args(stroke, last) : args;
  if (!resolved) return { close: true };
  return { run: binding.run, args: resolved };
}
