const KEYS = { left: "ctrl+h", down: "ctrl+j", up: "ctrl+k", right: "ctrl+l" };

export function route(direction, focus, panes) {
  if (!Object.hasOwn(KEYS, direction) || !focus?.pane) return null;
  const pane = panes.find((p) => p.pane === focus.pane);
  if (!focus.shown && pane?.program?.key === "nvim") return { terminal: focus.terminal, keys: KEYS[direction] };
  return { go: direction };
}
