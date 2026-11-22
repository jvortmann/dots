export function observeTabs(history, spaces) {
  const space = shown(spaces);
  const tab = space?.tabs.find((t) => t.active);
  const open = Object.fromEntries(spaces.filter((s) => history[s.id]).map((s) => [s.id, history[s.id]]));
  if (!tab) return open;
  const live = new Set(space.tabs.map((t) => t.id));
  const before = (history[space.id] ?? []).filter((id) => live.has(id) && id !== tab.id);
  return { ...open, [space.id]: [tab.id, ...before].slice(0, 2) };
}

export function observeSpaces(history, spaces) {
  const space = shown(spaces);
  if (!space) return history;
  const open = new Set(spaces.map((s) => s.id));
  return [space.id, ...history.filter((id) => open.has(id) && id !== space.id)];
}

export function lastTab(history, spaces) {
  return history[shown(spaces)?.id]?.[1] ?? null;
}

function shown(spaces) {
  return spaces.find((s) => s.active);
}
