import assert from "node:assert/strict";
import childProcess from "node:child_process";
import { unlinkSync, writeFileSync } from "node:fs";
import { syncBuiltinESMExports } from "node:module";
import { homedir, tmpdir } from "node:os";
import { join } from "node:path";
import { beforeEach, test } from "node:test";

// The extension runs hc with execFile. The fake records each call of hc as its
// arguments. With hc missing, it fails as execFile does for a missing file.
// While hc.held is a list, hc answers no call: the fake adds the callback of
// each call to the list, and the test answers them. As execFile does, the fake
// also ends a call with an error when the timeout of its options passes.
const hc = { calls: [], missing: false, held: null };
childProcess.execFile = (file, args, ...rest) => {
  const callback = rest.pop();
  const [options] = rest;
  if (hc.missing) return callback(Object.assign(new Error(`spawn ${file} ENOENT`), { code: "ENOENT" }));
  hc.calls.push(file === join(homedir(), ".local/bin/hc") ? args.join(" ") : `not hc: ${file}`);
  if (!hc.held) return callback(null, "", "");
  let timer;
  const answer = (...results) => {
    clearTimeout(timer);
    callback(...results);
  };
  hc.held.push(answer);
  if (options?.timeout) timer = setTimeout(() => answer(Object.assign(new Error("killed"), { killed: true })), options.timeout);
};
syncBuiltinESMExports();

const { default: extension } = await import("../../../pi/extensions/herdr-restore.ts");

const signals = ["SIGTERM", "SIGHUP"];
let sessionFile;
let sessions = 0;
beforeEach((t) => {
  hc.calls = [];
  hc.missing = false;
  hc.held = null;
  sessionFile = join(tmpdir(), `herdr-restore-${process.pid}-${sessions++}_a b.jsonl`);
  const listeners = Object.fromEntries(signals.map((signal) => [signal, process.listeners(signal)]));
  t.after(() => {
    try {
      unlinkSync(sessionFile);
    } catch {}
    for (const signal of signals) {
      for (const listener of process.listeners(signal)) {
        if (!listeners[signal].includes(listener)) process.off(signal, listener);
      }
    }
  });
});

test("a session with a file records the file at its start", async () => {
  writeFileSync(sessionFile, "");
  await runEvents(["session_start"]);
  assert.equal(hcCalls(), `label t7 restore.pi=${sessionFile}`);
});

test("a new session records nothing before pi writes its file", async () => {
  await runEvents(["session_start", "message_end"]);
  assert.equal(hcCalls(), "");
});

test("a new session records its file once pi writes it", async () => {
  await runEvents(["session_start", "message_end", "write", "message_end"]);
  assert.equal(hcCalls(), `label t7 restore.pi=${sessionFile}`);
});

test("a session records its file once and not for each message", async () => {
  await runEvents(["session_start", "write", "message_end", "message_end", "message_end"]);
  assert.equal(hcCalls(), `label t7 restore.pi=${sessionFile}`);
});

test("a subagent in the same pi records nothing", async () => {
  writeFileSync(sessionFile, "");
  await runEvents(["session_start", "message_end"], { mode: "print" });
  assert.equal(hcCalls(), "");
});

test("pi outside herdr calls no hc", async () => {
  writeFileSync(sessionFile, "");
  await runEvents(["session_start"], { terminal: "" });
  assert.deepEqual(hc.calls, []);
});

test("pi carries on in silence without hc", async () => {
  hc.missing = true;
  writeFileSync(sessionFile, "");
  assert.equal(await written(() => runEvents(["session_start", "quit"])), "");
});

test("a quit clears the record", async () => {
  writeFileSync(sessionFile, "");
  await runEvents(["session_start", "quit"]);
  assert.equal(hcCalls(), `label t7 restore.pi=${sessionFile}\nlabel t7 restore.pi=`);
});

test("a subagent in the same pi clears nothing at its quit", async () => {
  await runEvents(["session_start", "quit"], { mode: "print" });
  assert.equal(hcCalls(), "");
});

// A listener for SIGTERM or SIGHUP replaces the default end of the process.
// So a mode other than "tui" must add none.
test("pi in another mode leaves SIGTERM and SIGHUP to end it", async () => {
  const before = signalListeners();
  await runEvents(["session_start"], { mode: "print" });
  assert.deepEqual(signalListeners(), before);
});

test("a session removes its signal listeners at its shutdown", async () => {
  const before = signalListeners();
  await runEvents(["session_start", "reload"]);
  assert.deepEqual(signalListeners(), before);
});

test("a quit waits until hc clears the record", async () => {
  hc.held = [];
  let ended = false;
  const quit = runEvents(["session_start", "quit"]).then(() => (ended = true));
  await settled();
  const endedBeforeHc = ended;
  for (const answer of hc.held) answer(null, "", "");
  await quit;
  assert.equal(endedBeforeHc, false);
});

test("a quit waits one second at most for a hung hc", async (t) => {
  t.mock.timers.enable({ apis: ["setTimeout"] });
  hc.held = [];
  let ended = false;
  runEvents(["session_start", "quit"]).then(() => (ended = true));
  await settled();
  t.mock.timers.tick(1000);
  await settled();
  assert.equal(ended, true);
});

// On these signals pi also shuts down with the reason "quit", as at a reboot.
// The next start needs the record then.
for (const signal of ["SIGTERM", "SIGHUP"]) {
  test(`a quit on ${signal} keeps the record`, async () => {
    writeFileSync(sessionFile, "");
    await runEvents(["session_start", signal, "quit"]);
    assert.equal(hcCalls(), `label t7 restore.pi=${sessionFile}`);
  });
}

// A session_start follows each of these shutdowns and records its file again,
// so the shutdown must not clear the record.
for (const reason of ["reload", "new", "resume", "fork"]) {
  test(`a ${reason} keeps the record`, async () => {
    writeFileSync(sessionFile, "");
    await runEvents(["session_start", reason]);
    assert.equal(hcCalls(), `label t7 restore.pi=${sessionFile}`);
  });
}

function signalListeners() {
  return signals.map((signal) => process.listenerCount(signal));
}

function settled() {
  return new Promise(setImmediate);
}

function hcCalls() {
  return hc.calls.join("\n");
}

const shutdownReasons = ["quit", "reload", "new", "resume", "fork"];

// Loads the extension in a Herdr terminal with the id t7. It sends each event
// in turn, and waits for each handler to end. The context has the mode
// "tui", unless the options name another. The event "write" is no event of pi:
// it creates the session file, as pi does after the first message. Each name in
// shutdownReasons is a session_shutdown with that reason. The events "SIGTERM"
// and "SIGHUP" send that signal to the process.
async function runEvents(events, { terminal = "t7", mode = "tui" } = {}) {
  process.env.HC_TERMINAL_ID = terminal;
  const handlers = {};
  const ctx = { mode, sessionManager: { getSessionFile: () => sessionFile } };
  const send = async (type, fields) => {
    for (const handler of handlers[type] ?? []) await handler({ type, ...fields }, ctx);
  };
  extension({ on: (name, handler) => { (handlers[name] ??= []).push(handler); } });
  for (const event of events) {
    if (event === "write") writeFileSync(sessionFile, "{}\n");
    else if (event.startsWith("SIG")) process.emit(event);
    else if (shutdownReasons.includes(event)) await send("session_shutdown", { reason: event });
    else await send(event);
  }
}

// Runs the function, and gives what the process wrote to stdout and stderr
// while it ran.
async function written(run) {
  const chunks = [];
  const streams = [process.stdout, process.stderr].map((stream) => [stream, stream.write]);
  for (const [stream] of streams) stream.write = (chunk) => chunks.push(String(chunk));
  try {
    await run();
  } finally {
    for (const [stream, write] of streams) stream.write = write;
  }
  return chunks.join("");
}
