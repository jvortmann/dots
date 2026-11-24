import assert from "node:assert/strict";
import childProcess from "node:child_process";
import { unlinkSync, writeFileSync } from "node:fs";
import { syncBuiltinESMExports } from "node:module";
import { homedir, tmpdir } from "node:os";
import { join } from "node:path";
import { beforeEach, test } from "node:test";

// The extension runs hc with execFile. The fake records each call of hc as its
// arguments. With hc missing, it fails as execFile does for a missing file.
const hc = { calls: [], missing: false };
childProcess.execFile = (file, args, callback) => {
  if (hc.missing) return callback(Object.assign(new Error(`spawn ${file} ENOENT`), { code: "ENOENT" }));
  hc.calls.push(file === join(homedir(), ".local/bin/hc") ? args.join(" ") : `not hc: ${file}`);
  callback(null, "", "");
};
syncBuiltinESMExports();

const { default: extension } = await import("../../../pi/extensions/herdr-restore.ts");

let sessionFile;
let sessions = 0;
beforeEach((t) => {
  hc.calls = [];
  hc.missing = false;
  sessionFile = join(tmpdir(), `herdr-restore-${process.pid}-${sessions++}_a b.jsonl`);
  t.after(() => {
    try {
      unlinkSync(sessionFile);
    } catch {}
  });
});

test("a session with a file records the file at its start", () => {
  writeFileSync(sessionFile, "");
  runEvents(["session_start"]);
  assert.equal(hcCalls(), `label t7 restore.pi=${sessionFile}`);
});

test("a new session records nothing before pi writes its file", () => {
  runEvents(["session_start", "message_end"]);
  assert.equal(hcCalls(), "");
});

test("a new session records its file once pi writes it", () => {
  runEvents(["session_start", "message_end", "write", "message_end"]);
  assert.equal(hcCalls(), `label t7 restore.pi=${sessionFile}`);
});

test("a session records its file once and not for each message", () => {
  runEvents(["session_start", "write", "message_end", "message_end", "message_end"]);
  assert.equal(hcCalls(), `label t7 restore.pi=${sessionFile}`);
});

test("a subagent in the same pi records nothing", () => {
  writeFileSync(sessionFile, "");
  runEvents(["session_start", "message_end"], { mode: "print" });
  assert.equal(hcCalls(), "");
});

test("pi outside herdr calls no hc", () => {
  writeFileSync(sessionFile, "");
  runEvents(["session_start"], { terminal: "" });
  assert.deepEqual(hc.calls, []);
});

test("pi carries on in silence without hc", () => {
  hc.missing = true;
  writeFileSync(sessionFile, "");
  assert.equal(runEvents(["session_start"]), "");
});

// pi also shuts down on SIGTERM and SIGHUP, as at a reboot, and the next start
// needs the record then.
test("a session keeps its record when pi shuts down", () => {
  writeFileSync(sessionFile, "");
  runEvents(["session_start", "session_shutdown"]);
  assert.equal(hcCalls(), `label t7 restore.pi=${sessionFile}`);
});

function hcCalls() {
  return hc.calls.join("\n");
}

// Loads the extension in a Herdr terminal with the id t7, and sends it each
// event in turn. The context has the mode "tui", unless the options name
// another. The event "write" is no event of pi: it creates the session file,
// as pi does after the first message. Gives what the extension wrote to
// stdout and stderr.
function runEvents(events, { terminal = "t7", mode = "tui" } = {}) {
  process.env.HC_TERMINAL_ID = terminal;
  const handlers = {};
  const ctx = { mode, sessionManager: { getSessionFile: () => sessionFile } };
  const written = [];
  const streams = [process.stdout, process.stderr].map((stream) => [stream, stream.write]);
  for (const [stream] of streams) stream.write = (chunk) => written.push(String(chunk));
  try {
    extension({ on: (name, handler) => { handlers[name] = handler; } });
    for (const event of events) {
      if (event === "write") writeFileSync(sessionFile, "{}\n");
      else handlers[event]?.({ type: event }, ctx);
    }
  } finally {
    for (const [stream, write] of streams) stream.write = write;
  }
  return written.join("");
}
