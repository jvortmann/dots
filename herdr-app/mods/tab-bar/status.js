const DAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

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

export function agentList(list) {
  return list.map((a, i) => ({ ...a, number: i < 9 ? i + 1 : null }));
}

export function statusWord(status) {
  return status === "blocked" ? "needs you" : status;
}

export function listKey(key, at, count) {
  if (count === 0) return null;
  const chosen = Math.min(at, count - 1);
  if (key === "down") return { chosen: Math.min(count - 1, chosen + 1) };
  if (key === "up") return { chosen: Math.max(0, chosen - 1) };
  if (key === "enter") return { go: chosen };
  if (/^[1-9]$/.test(key) && Number(key) <= count) return { go: Number(key) - 1 };
  return null;
}

export function machineLabel(space, host) {
  return space.machine ? { icon: "server", name: space.machine } : { icon: "monitor", name: host || "This computer" };
}

export function untilNextMinute(date) {
  return 60000 - (date.getTime() % 60000);
}

function two(n) {
  return String(n).padStart(2, "0");
}
