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
// The extension acts only in the main tui session, in a Herdr terminal. It
// unsubscribes on session_shutdown, because pi keeps one event bus across
// /reload.
//
// Not handled: an error result, where we write done. Also a dialog close or a
// rename while subagents run. The report of the core wins until the next
// subagent event.

import { randomUUID } from "node:crypto";
import { formatProgramStatus } from "@earendil-works/pi-tui";

export default function (pi) {
  if (!process.env.HC_TERMINAL_ID) return;
  const running = new Set();
  let runActive = false;
  let reporting = false;
  let aborted = false;
  const unsubscribes = [];
  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    track("subagents:started", (id) => running.add(id));
    track("subagents:completed", (id) => running.delete(id));
    track("subagents:failed", (id) => running.delete(id));
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

  function track(channel, change) {
    listen(channel, ({ id }) => {
      change(id);
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
      for (const agent of reply.data.agents) if (agent.status === "running") running.add(agent.id);
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
