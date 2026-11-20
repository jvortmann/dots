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

export function machineLabel(space, host) {
  return space.machine ? { icon: "server", name: space.machine } : { icon: "monitor", name: host || "This computer" };
}

export function untilNextMinute(date) {
  return 60000 - (date.getTime() % 60000);
}

function two(n) {
  return String(n).padStart(2, "0");
}
