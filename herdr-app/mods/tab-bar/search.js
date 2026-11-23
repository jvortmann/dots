export const FILTERS = ["all", "blocked", "working", "done"];

export function filterRows(rows, filter, query) {
  const q = query.toLowerCase();
  const matches = (r) => [r.space_name, r.tab_name, r.program?.name, r.title, r.msg].join(" ").toLowerCase().includes(q);
  return groups(rows)
    .filter(([agent]) => filter === "all" || agent.status === filter)
    .filter((group) => group.some(matches))
    .flat();
}

export function filterCounts(rows, query) {
  return Object.fromEntries(FILTERS.map((f) => [f, filterRows(rows, f, query).filter((r) => !r.depth).length]));
}

export function nextFilter(filter, step) {
  return FILTERS[(FILTERS.indexOf(filter) + step + FILTERS.length) % FILTERS.length];
}

export function pickedFilter(filter, wanted) {
  return wanted === filter ? "all" : wanted;
}

export function filterOfCommand(command) {
  const name = command.replace(/^filter-/, "");
  return name !== command && FILTERS.includes(name) ? name : null;
}

export function rowOf(rows, key) {
  return Math.max(0, rows.findIndex((r) => r.key === key));
}

// Each agent row with the child rows after it.
function groups(rows) {
  return rows.reduce((all, r) => (r.depth ? all.at(-1).push(r) : all.push([r]), all), []);
}
