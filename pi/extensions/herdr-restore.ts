// In a Herdr terminal, record the session file of pi in the label restore.pi
// of the terminal, so that a lost terminal can resume the session. pi writes
// the file only after the first message. So the extension records the file at
// a session start when it exists, and else at the first message after it
// exists. It records each file once. It records only for the interactive pi
// (mode "tui"), because a subagent in the same pi loads the extension too and
// would label the terminal of its parent. It clears no label at shutdown,
// because pi also shuts down on SIGTERM and SIGHUP, as at a reboot. Outside
// Herdr, HC_TERMINAL_ID is not set, and the extension does nothing. hc is not
// on PATH, and a missing hc stays silent.

import { execFile } from "node:child_process";
import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

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
}

function record(terminal, file) {
  execFile(join(homedir(), ".local/bin/hc"), ["label", terminal, `restore.pi=${file}`], () => {});
}
