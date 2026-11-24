const AGENTS_KEPT = 30;

export function observeTabs(history, spaces) {
  const space = shown(spaces);
  const tab = space?.tabs.find((t) => t.active);
  const open = Object.fromEntries(spaces.filter((s) => history[s.id]).map((s) => [s.id, liveIn(history[s.id], s)]));
  if (!tab) return open;
  const seen = history[space.id] ?? [];
  const head = shownBeforeClose(seen, space) ?? tab.id;
  const before = liveIn(seen, space).filter((id) => id !== head);
  return { ...open, [space.id]: [head, ...before] };
}

export function observeSpaces(history, spaces) {
  const space = shown(spaces);
  if (!space) return history;
  const open = new Set(spaces.map((s) => s.id));
  return [space.id, ...history.filter((id) => open.has(id) && id !== space.id)];
}

export function observeAgents(history, agents) {
  const agent = agents.find((a) => a.focused);
  if (!agent) return history;
  return [agent.address, ...history.filter((id) => id !== agent.address)].slice(0, AGENTS_KEPT);
}

export function lastTab(history, spaces) {
  return history[shown(spaces)?.id]?.[1] ?? null;
}

export function tabToReturnTo(history, spaces) {
  const space = shown(spaces);
  const head = history[space?.id]?.[0];
  const tab = space?.tabs.find((t) => t.active);
  return head && tab && head !== tab.id ? head : null;
}

function shownBeforeClose(seen, space) {
  const live = liveIn(seen, space);
  return seen.length > 0 && live[0] !== seen[0] ? live[0] : undefined;
}

function liveIn(ids, space) {
  return ids.filter((id) => space.tabs.some((t) => t.id === id));
}

function shown(spaces) {
  return spaces.find((s) => s.active);
}
