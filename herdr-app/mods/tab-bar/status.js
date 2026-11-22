const DAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const KEEP_GONE_MS = 30 * 86400000;

// The time of the tmux status-right: `%a %d/%m/%y %R`.
export function timeText(date) {
  const dmy = [date.getDate(), date.getMonth() + 1, date.getFullYear() % 100].map(two).join("/");
  return `${DAYS[date.getDay()]} ${dmy} ${two(date.getHours())}:${two(date.getMinutes())}`;
}

export function agentsText(list) {
  return `${list.length} agents`;
}

export function needsText(list) {
  const needs = list.filter((a) => a.status === "blocked").length;
  return needs ? `· ${needs} needs you` : "";
}

export function agentList(list, records = {}, changed = {}, now = 0) {
  return list.flatMap((a, i) => [
    { ...a, key: a.address, number: i < 9 ? i + 1 : null, time: a.address in changed ? duration(now - changed[a.address].at) : "" },
    ...childRows(a.address, records[a.address] ?? {}),
  ]);
}

export function listKey(key, at, rows) {
  const count = rows.length;
  if (count === 0) return null;
  const chosen = Math.min(at, count - 1);
  if (key === "down" || key === "j") return { chosen: Math.min(count - 1, chosen + 1) };
  if (key === "up" || key === "k") return { chosen: Math.max(0, chosen - 1) };
  if (key === "enter") return { go: chosen };
  const numbered = /^[1-9]$/.test(key) ? rows.findIndex((r) => r.number === Number(key)) : -1;
  return numbered === -1 ? null : { go: numbered };
}

export function stampChanges(changed, list, now) {
  const state = (a) => (a.status === "done" ? "idle" : a.status);
  const fresh = list.filter((a) => changed[a.address]?.s !== state(a));
  const listed = new Set(list.map((a) => a.address));
  const kept = Object.entries(changed).filter(([address, c]) => listed.has(address) || now - c.at <= KEEP_GONE_MS);
  return { ...Object.fromEntries(kept), ...Object.fromEntries(fresh.map((a) => [a.address, { s: state(a), at: now }])) };
}

export function machineLabel(space, host) {
  return space.machine ? { icon: "server", name: space.machine } : { icon: "monitor", name: host || "This computer" };
}

export function untilNextMinute(date) {
  return 60000 - (date.getTime() % 60000);
}

function childRows(address, records) {
  return Object.keys(records)
    .map((id) => id.split("/"))
    .sort(byPath)
    .map((path) => {
      const id = path.join("/");
      const r = records[id];
      return { key: `${address}:${id}`, address, depth: depthOf(path, records), status: childStatus(r.state), title: r.title ?? "", msg: r.msg ?? "" };
    });
}

function childStatus(state) {
  return state === "error" ? "blocked" : state === "done" ? "idle" : state;
}

// One level for the record, and one for each ancestor that has a record.
function depthOf(path, records) {
  const ancestors = path.slice(0, -1).map((_, i) => path.slice(0, i + 1).join("/"));
  return 1 + ancestors.filter((id) => id in records).length;
}

function byPath(a, b) {
  const i = a.findIndex((part, at) => part !== b[at]);
  if (i === -1) return a.length - b.length;
  return i >= b.length ? 1 : a[i] < b[i] ? -1 : 1;
}

// The format of the time in a row of the stock sidebar.
function duration(ms) {
  const m = Math.floor(ms / 60000);
  if (m < 1) return "<1m";
  if (m < 60) return `${m}m`;
  const h = Math.floor(m / 60);
  return h < 24 ? `${h}h` : `${Math.floor(h / 24)}d`;
}

function two(n) {
  return String(n).padStart(2, "0");
}
