const DAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

// The tmux status-right: `#(hostname -s) %a %d/%m/%y %R`.
export function statusText(host, date) {
  const dmy = [date.getDate(), date.getMonth() + 1, date.getFullYear() % 100].map(two).join("/");
  const time = `${DAYS[date.getDay()]} ${dmy} ${two(date.getHours())}:${two(date.getMinutes())}`;
  return host ? `${host} ${time}` : time;
}

export function untilNextMinute(date) {
  return 60000 - (date.getTime() % 60000);
}

function two(n) {
  return String(n).padStart(2, "0");
}
