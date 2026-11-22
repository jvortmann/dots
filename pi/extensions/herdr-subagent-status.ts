// In a Herdr terminal, pi shows "working" only during its own run. The core
// reports done at agent_settled, while background subagents still run. This
// extension keeps the ids of the running subagents. After the report of the
// core (setTimeout), it writes an OSC 7501 working record, "N subagents".
// When the last subagent ends, it writes what the core wrote: done with the
// session name, or idle after an abort.
//
// The core skips a report that equals its last one, so it does not overwrite
// our record. For the same reason, when we release, we must write the final
// state ourselves. The terminal replays the stored status of the core after
// ctrl+z or the external editor (pi-tui terminal.js:217). Our record returns
// at the next subagent start or end.
//
// The extension also writes one OSC 7501 child record for each running
// subagent. The id is sub/<id>, the title is the type, and the msg is the
// description. A subagent that a subagent started goes under the id of its
// parent: sub/<parent>/<id>. When a subagent ends, its record gets clear,
// which removes it, because done stays until something replaces it. A seed
// first clears sub, to remove the records that an older copy left. It then
// begins the agents parents first, by depth, so a nested subagent goes under
// its parent whatever the order of the list. The extension writes child
// records also during the run of the core. The core writes no child records.
//
// The extension acts only in the main tui session, in a Herdr terminal. It
// unsubscribes on session_shutdown, because pi keeps one event bus across
// /reload.
//
// Not handled: an error result, where we write done. Also a parent that ends
// before its child. Its clear also removes the record of the child, while the
// count of the working record still includes the child. Also a dialog close or
// a rename while subagents run. The report of the core wins until the next
// subagent event.

import { randomUUID } from "node:crypto";
import { formatProgramStatus } from "@earendil-works/pi-tui";

export default function (pi) {
  if (!process.env.HC_TERMINAL_ID) return;
  const running = new Map();
  let runActive = false;
  let reporting = false;
  let aborted = false;
  const unsubscribes = [];
  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    track("subagents:started", begin);
    track("subagents:completed", end);
    track("subagents:failed", end);
    listen("subagents:ready", seed);
    seed();
  });
  pi.on("session_shutdown", () => {
    for (const unsubscribe of unsubscribes.splice(0)) unsubscribe();
  });
  pi.on("agent_start", () => {
    runActive = true;
    reporting = false;
  });
  pi.on("agent_settled", (event) => {
    runActive = false;
    aborted = event.aborted;
    setTimeout(report);
  });

  function begin(agent) {
    running.set(agent.id, `${running.get(agent.parentAgentId) ?? "sub"}/${agent.id}`);
    writeRecord({ state: "working", id: running.get(agent.id), title: agent.type, message: agent.description });
  }

  function end(agent) {
    writeRecord({ state: "clear", id: running.get(agent.id) ?? `sub/${agent.id}` });
    running.delete(agent.id);
  }

  function track(channel, change) {
    listen(channel, (agent) => {
      change(agent);
      setTimeout(report);
    });
  }

  function listen(channel, handler) {
    unsubscribes.push(pi.events.on(channel, handler));
  }

  function seed() {
    const requestId = randomUUID();
    const stop = pi.events.on(`subagents:rpc:list:reply:${requestId}`, (reply) => {
      stop();
      if (!reply.success) return;
      running.clear();
      writeRecord({ state: "clear", id: "sub" });
      const agents = reply.data.agents.filter((agent) => agent.status === "running");
      for (const agent of agents.sort((a, b) => a.depth - b.depth)) begin(agent);
      setTimeout(report);
    });
    unsubscribes.push(stop);
    pi.events.emit("subagents:rpc:list", { requestId });
  }

  function report() {
    if (runActive) return;
    if (running.size > 0) {
      reporting = true;
      const count = running.size;
      write({ state: "working", message: `${count} subagent${count === 1 ? "" : "s"}` });
    } else if (reporting) {
      reporting = false;
      write(aborted ? { state: "idle" } : { state: "done", message: pi.getSessionName() });
    }
  }
}

function write(status) {
  process.stdout.write(formatProgramStatus({ ...status, app: "pi" }));
}

function writeRecord({ state, id, title, message }) {
  const pairs = [`state=${state}`, `id=${id}`];
  if (title) pairs.push(`title=${base64(title)}`);
  if (message) pairs.push(`msg=${base64(message)}`);
  process.stdout.write(`\x1b]7501;${pairs.join(":")}\x1b\\`);
}

function base64(text) {
  return Buffer.from(text, "utf8").toString("base64");
}
