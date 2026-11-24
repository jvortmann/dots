// In a Herdr terminal, record the session file of pi in the label restore.pi
// of the terminal, so that a lost terminal can resume the session. pi writes
// the file only after the first message. So the extension records the file at
// a session start when it exists, and else at the first message after it
// exists. It records each file once. It records and clears only for the
// interactive pi (mode "tui"), because a subagent in the same pi loads the
// extension too and would change the label of its parent. The extension clears
// the label when the user quits pi. It keeps the label when SIGTERM or SIGHUP
// ends pi, as at a reboot, so that the terminal can resume the session. pi
// gives the reason "quit" in both cases, so the extension listens for the two
// signals itself. A hung hc holds the quit for one second at most. Outside
// Herdr, HC_TERMINAL_ID is not set, and the extension does nothing. hc is not
// on PATH, and a missing hc stays silent.

import { execFile } from "node:child_process";
import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const signals = ["SIGTERM", "SIGHUP"];

export default function (pi) {
  const terminal = process.env.HC_TERMINAL_ID;
  if (!terminal) return;
  let recorded;
  const recordSessionFile = (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    const file = ctx.sessionManager.getSessionFile();
    if (file === recorded || !existsSync(file)) return;
    recorded = file;
    record(terminal, file);
  };
  pi.on("session_start", recordSessionFile);
  pi.on("message_end", recordSessionFile);
  let signalled = false;
  const onSignal = () => (signalled = true);
  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    for (const signal of signals) process.on(signal, onSignal);
  });
  pi.on("session_shutdown", (event, ctx) => {
    for (const signal of signals) process.off(signal, onSignal);
    if (ctx.mode === "tui" && event.reason === "quit" && !signalled) return clear(terminal);
  });
}

function record(terminal, file) {
  execFile(hcPath(), ["label", terminal, `restore.pi=${file}`], () => {});
}

function clear(terminal) {
  return new Promise((resolve) => {
    execFile(hcPath(), ["label", terminal, "restore.pi="], { timeout: 1000 }, () => resolve());
  });
}

function hcPath() {
  return join(homedir(), ".local/bin/hc");
}
