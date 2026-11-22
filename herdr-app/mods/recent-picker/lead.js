// The pane a tab's tab speaks for: the focused one, else its agent, else the first.
export function lead(all, id) {
  const mine = all.filter((p) => p.tab === id);
  return mine.find((p) => p.focused) ?? mine.find((p) => p.program?.agent) ?? mine[0];
}
