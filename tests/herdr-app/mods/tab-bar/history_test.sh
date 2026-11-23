#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
HISTORY="$ROOT/herdr-app/mods/tab-bar/history.js"
SHOTS="$ROOT/tests/herdr-app/mods/shots.js"

function set_up() {
  [[ -f $HISTORY ]] || bashunit::fail "missing the file under test: $HISTORY"
}

function test_after_a_switch_the_last_tab_is_the_tab_shown_before() {
  assert_same "t1" "$(last_tab_after "*s1:*t1,t2" "*s1:t1,*t2")"
}

function test_going_back_to_the_last_tab_makes_the_tab_left_the_last_tab() {
  assert_same "t2" "$(last_tab_after "*s1:*t1,t2" "*s1:t1,*t2" "*s1:*t1,t2")"
}

function test_each_space_keeps_its_own_last_tab() {
  assert_same "t1" "$(last_tab_after \
    "*s1:*t1,t2 s2:*u1,u2" \
    "*s1:t1,*t2 s2:*u1,u2" \
    "s1:t1,*t2 *s2:*u1,u2" \
    "s1:t1,*t2 *s2:u1,*u2" \
    "*s1:t1,*t2 s2:u1,*u2")"
}

function test_a_closed_tab_is_no_longer_the_last_tab() {
  assert_same "null" "$(last_tab_after "*s1:*t1,t2" "*s1:t1,*t2" "*s1:*t1")"
}

function test_the_record_forgets_a_closed_space() {
  assert_same "s1" "$(spaces_in_record_after "*s1:*t1 s2:*u1" "s1:*t1 *s2:*u1" "*s1:*t1")"
}

function test_the_spaces_go_from_the_shown_space_to_the_space_shown_longest_ago() {
  assert_same "s2 s3 s1" "$(spaces_by_recency_after "*s1:*t1 s2:*u1 s3:*v1" "s1:*t1 s2:*u1 *s3:*v1" "s1:*t1 *s2:*u1 s3:*v1")"
}

function test_the_space_history_forgets_a_closed_space() {
  assert_same "s1" "$(spaces_by_recency_after "*s1:*t1 s2:*u1" "s1:*t1 *s2:*u1" "*s1:*t1")"
}

function test_the_agents_go_from_the_agent_focused_last_to_the_agent_focused_longest_ago() {
  assert_same "t2 t1" "$(agents_by_recency_after "*t1 t2" "t1 *t2")"
}

function test_an_agent_that_gets_the_focus_again_moves_to_the_front_once() {
  assert_same "t1 t2" "$(agents_by_recency_after "*t1 t2" "t1 *t2" "*t1 t2")"
}

function test_focus_on_a_pane_with_no_agent_keeps_the_agent_history() {
  assert_same "t2 t1" "$(agents_by_recency_after "*t1 t2" "t1 *t2" "t1 t2")"
}

# The history drops the oldest id, so it cannot grow without bound.
function test_the_agent_history_keeps_the_30_agents_focused_last() {
  local seen
  seen=$(agents_by_recency_after $(printf '*t%s ' {1..31}))
  assert_same "30 t31 t2" "$(wc -w <<<"$seen" | tr -d ' ') $(awk '{ print $1, $NF }' <<<"$seen")"
}

# Shows each argument to the history in turn, and prints the last tab of the
# shown space after the last one, or null. An argument lists the spaces, as in
# "*s1:t1,*t2 s2:*u1": a star marks the shown space, and the tab that a space shows.
last_tab_after() {
  observe last-tab "$@"
}

# Shows each argument to the history in turn, as last_tab_after does, and
# prints the spaces that the record keeps.
spaces_in_record_after() {
  observe spaces "$@"
}

# Shows each argument to the space history in turn, and prints its spaces.
spaces_by_recency_after() {
  observe recency "$@"
}

# Shows each argument to the agent history in turn, and prints its agents. An
# argument lists the agents, as in "t1 *t2": a star marks the focused agent.
agents_by_recency_after() {
  HISTORY="$HISTORY" mise x node@latest -- node --input-type=module -e '
    const { observeAgents } = await import(process.env.HISTORY);
    const shots = process.argv.slice(1).map((shot) => shot.split(" ").map((a) => ({ address: a.replace("*", ""), focused: a.startsWith("*") })));
    console.log(shots.reduce((seen, shot) => observeAgents(seen, shot), []).join(" "));
  ' "$@" 2>&1
}

observe() {
  PRINT="$1" HISTORY="$HISTORY" SHOTS="$SHOTS" mise x node@latest -- node --input-type=module -e '
    const { observeTabs, observeSpaces, lastTab } = await import(process.env.HISTORY);
    const { parseShot } = await import(process.env.SHOTS);
    const shots = process.argv.slice(1).map(parseShot);
    const history = shots.reduce((seen, shot) => observeTabs(seen, shot), {});
    if (process.env.PRINT === "recency") console.log(shots.reduce((seen, shot) => observeSpaces(seen, shot), []).join(" "));
    else if (process.env.PRINT === "spaces") console.log(Object.keys(history).join(" "));
    else console.log(String(lastTab(history, shots.at(-1))));
  ' "${@:2}"
}
