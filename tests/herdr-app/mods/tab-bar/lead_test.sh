#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
LEAD="$ROOT/herdr-app/mods/tab-bar/lead.js"

function set_up() {
  [[ -f $LEAD ]] || bashunit::fail "missing the file under test: $LEAD"
}

function test_the_focused_pane_of_a_tab_leads_it() {
  assert_same "nvim" "$(lead_of t1 '[{"tab":"t1","program":{"key":"shell"}},{"tab":"t1","focused":true,"program":{"key":"nvim"}}]')"
}

function test_the_focused_pane_leads_even_when_an_agent_runs_in_another_pane() {
  assert_same "shell" "$(lead_of t1 '[{"tab":"t1","program":{"key":"pi","agent":true}},{"tab":"t1","focused":true,"program":{"key":"shell"}}]')"
}

function test_with_no_focused_pane_the_agent_pane_leads() {
  assert_same "pi" "$(lead_of t1 '[{"tab":"t1","program":{"key":"shell"}},{"tab":"t1","program":{"key":"pi","agent":true}}]')"
}

function test_with_no_focused_pane_and_no_agent_the_first_pane_leads() {
  assert_same "shell" "$(lead_of t1 '[{"tab":"t1","program":{"key":"shell"}},{"tab":"t1","program":{"key":"nvim"}}]')"
}

function test_a_pane_of_another_tab_never_leads() {
  assert_same "shell" "$(lead_of t1 '[{"tab":"t2","focused":true,"program":{"key":"nvim"}},{"tab":"t1","program":{"key":"shell"}}]')"
}

# Prints the program key of the pane that leads tab $1, from the panes in $2,
# as JSON.
lead_of() {
  LEAD="$LEAD" mise x node@latest -- node --input-type=module -e '
    const { lead } = await import(process.env.LEAD);
    console.log(String(lead(JSON.parse(process.argv[2]), process.argv[1])?.program.key));
  ' "$1" "$2"
}
