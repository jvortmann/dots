#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
EXTENSION="$ROOT/pi/extensions/herdr-subagent-status.ts"
# shellcheck source=node.sh
source "$ROOT/tests/pi/extensions/node.sh"

function set_up() {
  [[ -f $EXTENSION ]] || bashunit::fail "missing the file under test: $EXTENSION"
  find_node
  find_pi_tui
  HOME_DIR=$(bashunit::temp_dir "home")
}

function test_pi_stays_working_while_a_background_subagent_runs_after_its_run() {
  assert_same $'core done my session\nworking 1 subagent' "$(run_status start started:a settle)"
}

function test_pi_turns_working_when_a_subagent_starts_while_pi_is_idle() {
  assert_same "working 1 subagent" "$(run_status started:a)"
}

# The core reports working during its own run, and done after it.
function test_a_subagent_that_ends_during_a_run_leaves_the_status_to_the_core() {
  assert_same $'working 1 subagent\ncore done my session' "$(run_status started:a start completed:a settle)"
}

function test_pi_reports_done_when_its_last_subagent_ends() {
  assert_same $'core done my session\nworking 2 subagents\nworking 1 subagent\ndone my session' \
    "$(run_status start started:a started:b settle completed:a failed:b)"
}

function test_pi_reports_idle_when_its_last_subagent_ends_after_an_abort() {
  assert_same $'core idle\nworking 1 subagent\nidle' "$(run_status start started:a settle-aborted completed:a)"
}

function test_outside_herdr_the_extension_writes_nothing() {
  assert_same "core done my session" "$(TERMINAL_ID="" run_status start started:a settle)"
}

function test_a_subagent_in_the_same_pi_writes_nothing() {
  assert_same "core done my session" "$(MODE=print run_status start started:a settle)"
}

function test_pi_counts_the_subagents_that_ran_before_pi_subagents_was_ready() {
  assert_same $'working 2 subagents\nworking 1 subagent' "$(run_status ready:a,b completed:a)"
}

# pi keeps its event bus across a reload, so the old copy must stop listening.
function test_after_a_reload_pi_counts_a_subagent_once() {
  assert_same "working 1 subagent" "$(run_status reload started:a)"
}

# pi-subagents sends subagents:ready on its own session_start, which can run
# before the session_start of this extension.
function test_pi_counts_the_subagents_that_ran_when_pi_subagents_was_ready_first() {
  assert_same "working 1 subagent" "$(LISTED=a run_status)"
}

function test_a_subagent_that_starts_shows_as_a_working_record_with_its_type_and_description() {
  assert_same "working sub/a Explore: find a" "$(SHOW=children run_status started:a)"
}

# A done record stays until something replaces it, and clear removes it.
function test_a_subagent_that_ends_takes_its_record_away() {
  assert_same $'working sub/a Explore: find a\nworking sub/b Explore: find b\nclear sub/a\nclear sub/b' \
    "$(SHOW=children run_status started:a started:b completed:a failed:b)"
}

# In OSC 7501, the record sub/a/b is a child of the record sub/a.
function test_a_subagent_that_a_subagent_started_shows_under_the_record_of_its_parent() {
  assert_same $'working sub/a Explore: find a\nworking sub/a/b Explore: find b\nclear sub/a/b' \
    "$(SHOW=children run_status started:a started:b@a completed:b@a)"
}

# A clear of sub removes the records that an older copy left, such as the
# record of a subagent that ended during a reload.
function test_the_subagents_that_ran_before_the_session_start_show_as_records() {
  assert_same $'clear sub\nworking sub/a Explore: find a\nworking sub/a/b Explore: find b' \
    "$(SHOW=children run_status ready:a,b@a)"
}

function test_a_subagent_that_ran_before_the_session_start_shows_under_its_parent_in_any_order() {
  assert_same $'clear sub\nworking sub/a Explore: find a\nworking sub/a/b Explore: find b' \
    "$(SHOW=children run_status ready:b@a,a)"
}

function test_outside_herdr_and_in_a_subagent_the_extension_writes_no_record() {
  assert_same "" "$(TERMINAL_ID="" SHOW=children run_status started:a)"
  assert_same "" "$(MODE=print SHOW=children run_status started:a)"
}

# Runs the extension in node, in a Herdr terminal with the id t7, with a fake
# pi and a fake event bus, and a session with the mode that MODE names, "tui"
# by default. Each argument is a step:
#   start              the main agent run starts
#   settle             the run settles, and then the core reports done
#   settle-aborted     the run settles after an abort, and the core reports idle
#   started:<id>       a subagent of the type Explore starts, to "find <id>",
#                      also completed:<id> and failed:<id>
#   ready:<id>,<id>    pi-subagents is ready, and its list holds these running
#   reload             the session shuts down, and a new copy of the extension
#                      starts a session on the same event bus
# An <id>@<parent> is a subagent that the subagent <parent> started.
# With LISTED set to ids, pi-subagents is ready before the session starts, and
# its list holds these running.
# Then it prints each OSC 7501 root record that the extension wrote, as the
# state and the message, and each record of the fake core with "core" before
# it. With SHOW=children, it prints each child record instead, as the state,
# the id, the title and the message.
# It prints any other output as JSON. pi gives the extension its own pi-tui,
# so a resolve hook points node at it.
run_status() {
  HOME="$HOME_DIR" HC_TERMINAL_ID=${TERMINAL_ID-t7} EXTENSION="$EXTENSION" PI_TUI="$PI_TUI" \
    MODE=${MODE-tui} LISTED=${LISTED-} SHOW=${SHOW-root} \
    "$NODE" --import "$PI_TUI_HOOK" --input-type=module -e '
    const listeners = {};
    const events = {
      on: (channel, handler) => {
        (listeners[channel] ??= new Set()).add(handler);
        return () => listeners[channel].delete(handler);
      },
      emit: (channel, data) => { for (const handler of [...(listeners[channel] ?? [])]) handler(data); },
    };
    const output = [];
    const write = process.stdout.write.bind(process.stdout);
    process.stdout.write = (chunk) => { output.push(String(chunk)); return true; };
    const ctx = { mode: process.env.MODE };
    const agent = (spec, status) => {
      const [id, parentAgentId] = spec.split("@");
      return { id, status, type: "Explore", description: `find ${id}`, depth: parentAgentId ? 2 : 1, ...(parentAgentId ? { parentAgentId } : {}) };
    };
    const answerList = (ids) => {
      const agents = ids.split(",").map((spec) => agent(spec, "running")).concat(agent("old", "completed"));
      events.on("subagents:rpc:list", ({ requestId }) => events.emit(`subagents:rpc:list:reply:${requestId}`, { success: true, data: { agents } }));
    };
    if (process.env.LISTED) answerList(process.env.LISTED);
    const tick = () => new Promise((resolve) => setTimeout(resolve, 20));
    let handlers;
    let copies = 0;
    const load = async () => {
      handlers = {};
      const pi = { on: (name, handler) => { handlers[name] = handler; }, events, getSessionName: () => "my session" };
      (await import(`${process.env.EXTENSION}?copy=${copies++}`)).default(pi);
      await handlers.session_start?.({ type: "session_start" }, ctx);
    };
    await load();
    await tick();
    for (const step of process.argv.slice(1)) {
      const [name, ids = ""] = step.split(":");
      if (name === "reload") {
        await handlers.session_shutdown?.({ type: "session_shutdown", reason: "reload" }, ctx);
        await load();
      }
      if (name === "start") await handlers.agent_start?.({ type: "agent_start" }, ctx);
      if (name === "settle" || name === "settle-aborted") {
        const aborted = name === "settle-aborted";
        await handlers.agent_settled?.({ type: "agent_settled", aborted }, ctx);
        output.push(aborted ? "core idle" : "core done my session");
      }
      if (["started", "completed", "failed"].includes(name)) events.emit(`subagents:${name}`, agent(ids, name === "started" ? "running" : name));
      if (name === "ready") {
        answerList(ids);
        events.emit("subagents:ready", {});
      }
      await tick();
    }
    process.stdout.write = write;
    for (const chunk of output) {
      const record = chunk.match(/^\x1b\]7501;([^\x1b]*)\x1b\\$/);
      const children = process.env.SHOW === "children";
      if (!record) {
        if (!children || !chunk.startsWith("core ")) console.log(chunk.startsWith("core ") ? chunk : JSON.stringify(chunk));
        continue;
      }
      const pairs = Object.fromEntries(record[1].split(":").map((pair) => pair.match(/^([^=]*)=(.*)$/).slice(1)));
      const text = (key) => (pairs[key] ? Buffer.from(pairs[key], "base64").toString() : "");
      const message = text("msg");
      if (children !== ("id" in pairs)) continue;
      if (children) {
        console.log([pairs.state, pairs.id, pairs.title && `${text("title")}:`, message].filter(Boolean).join(" "));
        continue;
      }
      console.log(`${pairs.state} ${message}`.trim() + (pairs.app === "pi" ? "" : ` app=${pairs.app}`));
    }
  ' "$@" 2>&1
}
