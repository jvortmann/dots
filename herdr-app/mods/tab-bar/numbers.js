export function numberTabs(record, spaces) {
  return { ...record, ...Object.fromEntries(spaces.map((s) => [s.id, numberSpace(record[s.id] ?? {}, s.tabs)])) };
}

export function nextMove(record, space) {
  const numbers = record[space.id] ?? {};
  const order = [...space.tabs].sort((a, b) => numbers[a.id] - numbers[b.id]);
  const at = order.findIndex((t, i) => t.id !== space.tabs[i].id);
  return at < 0 ? null : { id: order[at].id, index: at + 1 };
}

export function swapNumbers(record, space, by) {
  const at = space.tabs.findIndex((t) => t.active);
  const [a, b] = [space.tabs[at].id, space.tabs[(at + by + space.tabs.length) % space.tabs.length].id];
  const numbers = record[space.id];
  return { ...record, [space.id]: { ...numbers, [a]: numbers[b], [b]: numbers[a] } };
}

export function tabNumbered(record, space, number) {
  return space.tabs.find((t) => record[space.id]?.[t.id] === number)?.id ?? null;
}

function numberSpace(known, tabs) {
  const numbers = Object.fromEntries(tabs.filter((t) => known[t.id]).map((t) => [t.id, known[t.id]]));
  for (const t of tabs.filter((t) => !numbers[t.id])) numbers[t.id] = lowestFree(Object.values(numbers));
  return numbers;
}

function lowestFree(used) {
  let n = 1;
  while (used.includes(n)) n++;
  return n;
}
