import assert from "node:assert/strict";
import { test } from "node:test";
import { resolvePiTui } from "./pi-packages.mjs";

const skip = !resolvePiTui() && "needs pi from mise";
const EXTENSION = new URL("../../../pi/extensions/herdr-subagent-status.ts", import.meta.url).href;
const copies = skip ? [] : [(await import(`${EXTENSION}?copy=0`)).default, (await import(`${EXTENSION}?copy=1`)).default];

test("pi stays working while a background subagent runs after its run", { skip }, (t) => {
  assert.equal(runStatus(t, ["start", "started:a", "settle"]), "core done my session\nworking 1 subagent");
});

test("pi turns working when a subagent starts while pi is idle", { skip }, (t) => {
  assert.equal(runStatus(t, ["started:a"]), "working 1 subagent");
});

// The core reports working during its own run, and done after it.
test("a subagent that ends during a run leaves the status to the core", { skip }, (t) => {
  assert.equal(runStatus(t, ["started:a", "start", "completed:a", "settle"]), "working 1 subagent\ncore done my session");
});

test("pi reports done when its last subagent ends", { skip }, (t) => {
  assert.equal(
    runStatus(t, ["start", "started:a", "started:b", "settle", "completed:a", "failed:b"]),
    "core done my session\nworking 2 subagents\nworking 1 subagent\ndone my session",
  );
});

test("pi reports idle when its last subagent ends after an abort", { skip }, (t) => {
  assert.equal(runStatus(t, ["start", "started:a", "settle-aborted", "completed:a"]), "core idle\nworking 1 subagent\nidle");
});

test("outside herdr the extension writes nothing", { skip }, (t) => {
  assert.equal(runStatus(t, ["start", "started:a", "settle"], { terminal: "" }), "core done my session");
});

test("a subagent in the same pi writes nothing", { skip }, (t) => {
  assert.equal(runStatus(t, ["start", "started:a", "settle"], { mode: "print" }), "core done my session");
});

test("pi counts the subagents that ran before pi subagents was ready", { skip }, (t) => {
  assert.equal(runStatus(t, ["ready:a,b", "completed:a"]), "working 2 subagents\nworking 1 subagent");
});

// pi keeps its event bus across a reload, so the old copy must stop listening.
test("after a reload pi counts a subagent once", { skip }, (t) => {
  assert.equal(runStatus(t, ["reload", "started:a"]), "working 1 subagent");
});

// pi-subagents sends subagents:ready on its own session_start, which can run
// before the session_start of this extension.
test("pi counts the subagents that ran when pi subagents was ready first", { skip }, (t) => {
  assert.equal(runStatus(t, [], { listed: "a" }), "working 1 subagent");
});

test("a subagent that starts shows as a working record with its type and description", { skip }, (t) => {
  assert.equal(runStatus(t, ["started:a"], { show: "children" }), "working sub/a Explore: find a");
});

// A done record stays until something replaces it, and clear removes it.
test("a subagent that ends takes its record away", { skip }, (t) => {
  assert.equal(
    runStatus(t, ["started:a", "started:b", "completed:a", "failed:b"], { show: "children" }),
    "working sub/a Explore: find a\nworking sub/b Explore: find b\nclear sub/a\nclear sub/b",
  );
});

// In OSC 7501, the record sub/a/b is a child of the record sub/a.
test("a subagent that a subagent started shows under the record of its parent", { skip }, (t) => {
  assert.equal(
    runStatus(t, ["started:a", "started:b@a", "completed:b@a"], { show: "children" }),
    "working sub/a Explore: find a\nworking sub/a/b Explore: find b\nclear sub/a/b",
  );
});

// A clear of sub removes the records that an older copy left, such as the
// record of a subagent that ended during a reload.
test("the subagents that ran before the session start show as records", { skip }, (t) => {
  assert.equal(
    runStatus(t, ["ready:a,b@a"], { show: "children" }),
    "clear sub\nworking sub/a Explore: find a\nworking sub/a/b Explore: find b",
  );
});

test("a subagent that ran before the session start shows under its parent in any order", { skip }, (t) => {
  assert.equal(
    runStatus(t, ["ready:b@a,a"], { show: "children" }),
    "clear sub\nworking sub/a Explore: find a\nworking sub/a/b Explore: find b",
  );
});

test("outside herdr and in a subagent the extension writes no record", { skip }, (t) => {
  assert.equal(runStatus(t, ["started:a"], { terminal: "", show: "children" }), "");
  assert.equal(runStatus(t, ["started:a"], { mode: "print", show: "children" }), "");
});

// Runs the extension in a Herdr terminal with the id t7, with a fake pi and a
// fake event bus, and a session with the mode "tui", unless the options name
// another. The clock of the test runs each timer of the extension after each
// step. Each step is one of:
//   start              the main agent run starts
//   settle             the run settles, and then the core reports done
//   settle-aborted     the run settles after an abort, and the core reports idle
//   started:<id>       a subagent of the type Explore starts, to "find <id>",
//                      also completed:<id> and failed:<id>
//   ready:<id>,<id>    pi-subagents is ready, and its list holds these running
//   reload             the session shuts down, and a new copy of the extension
//                      starts a session on the same event bus
// An <id>@<parent> is a subagent that the subagent <parent> started.
// With listed set to ids, pi-subagents is ready before the session starts,
// and its list holds these running.
// Gives each OSC 7501 root record that the extension wrote, as the state and
// the message, and each record of the fake core with "core" before it. With
// show set to children, it gives each child record instead, as the state, the
// id, the title and the message. It gives any other output as JSON.
function runStatus(t, steps, { terminal = "t7", mode = "tui", listed = "", show = "root" } = {}) {
  t.mock.timers.enable({ apis: ["setTimeout"] });
  process.env.HC_TERMINAL_ID = terminal;
  const listeners = {};
  const events = {
    on: (channel, handler) => {
      (listeners[channel] ??= new Set()).add(handler);
      return () => listeners[channel].delete(handler);
    },
    emit: (channel, data) => {
      for (const handler of [...(listeners[channel] ?? [])]) handler(data);
    },
  };
  const ctx = { mode };
  const agent = (spec, status) => {
    const [id, parentAgentId] = spec.split("@");
    return { id, status, type: "Explore", description: `find ${id}`, depth: parentAgentId ? 2 : 1, ...(parentAgentId ? { parentAgentId } : {}) };
  };
  const answerList = (ids) => {
    const agents = ids.split(",").map((spec) => agent(spec, "running")).concat(agent("old", "completed"));
    events.on("subagents:rpc:list", ({ requestId }) => events.emit(`subagents:rpc:list:reply:${requestId}`, { success: true, data: { agents } }));
  };
  let handlers;
  let copy = 0;
  const load = () => {
    handlers = {};
    const pi = { on: (name, handler) => { handlers[name] = handler; }, events, getSessionName: () => "my session" };
    copies[copy++](pi);
    handlers.session_start?.({ type: "session_start" }, ctx);
  };
  const output = [];
  const streams = [process.stdout, process.stderr].map((stream) => [stream, stream.write]);
  for (const [stream] of streams) stream.write = (chunk) => output.push(String(chunk));
  try {
    if (listed) answerList(listed);
    load();
    t.mock.timers.runAll();
    for (const step of steps) {
      const [name, ids = ""] = step.split(":");
      if (name === "reload") {
        handlers.session_shutdown?.({ type: "session_shutdown", reason: "reload" }, ctx);
        load();
      }
      if (name === "start") handlers.agent_start?.({ type: "agent_start" }, ctx);
      if (name === "settle" || name === "settle-aborted") {
        const aborted = name === "settle-aborted";
        handlers.agent_settled?.({ type: "agent_settled", aborted }, ctx);
        output.push(aborted ? "core idle" : "core done my session");
      }
      if (["started", "completed", "failed"].includes(name)) events.emit(`subagents:${name}`, agent(ids, name === "started" ? "running" : name));
      if (name === "ready") {
        answerList(ids);
        events.emit("subagents:ready", {});
      }
      t.mock.timers.runAll();
    }
  } finally {
    for (const [stream, write] of streams) stream.write = write;
    t.mock.timers.reset();
  }
  return printed(output, show === "children");
}

function printed(output, children) {
  const lines = [];
  for (const chunk of output) {
    const record = chunk.match(/^\x1b\]7501;([^\x1b]*)\x1b\\$/);
    if (!record) {
      if (!children || !chunk.startsWith("core ")) lines.push(chunk.startsWith("core ") ? chunk : JSON.stringify(chunk));
      continue;
    }
    const pairs = Object.fromEntries(record[1].split(":").map((pair) => pair.match(/^([^=]*)=(.*)$/).slice(1)));
    const text = (key) => (pairs[key] ? Buffer.from(pairs[key], "base64").toString() : "");
    const message = text("msg");
    if (children !== ("id" in pairs)) continue;
    if (children) {
      lines.push([pairs.state, pairs.id, pairs.title && `${text("title")}:`, message].filter(Boolean).join(" "));
      continue;
    }
    lines.push(`${pairs.state} ${message}`.trim() + (pairs.app === "pi" ? "" : ` app=${pairs.app}`));
  }
  return lines.join("\n");
}
