export function recentSpaces(spaces, history) {
  const rank = (s) => (s.active ? -1 : history.includes(s.id) ? history.indexOf(s.id) : history.length);
  return [...spaces].sort((a, b) => rank(a) - rank(b));
}

export function openingTab(spaces, history) {
  const [shown, previous] = recentSpaces(spaces, history);
  return (previous ?? shown)?.tabs.find((t) => t.active)?.id ?? null;
}
