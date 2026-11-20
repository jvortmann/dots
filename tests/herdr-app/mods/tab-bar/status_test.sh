#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
STATUS="$ROOT/herdr-app/mods/tab-bar/status.js"

function set_up() {
  [[ -f $STATUS ]] || bashunit::fail "missing the file under test: $STATUS"
}

function test_shows_the_time_as_the_tmux_status_line_without_the_host() {
  assert_same "Mon 09/11/26 07:05" "$(status_of 'timeText(new Date("2026-11-09T07:05:42"))')"
}

function test_counts_every_agent() {
  assert_same "2 agents" "$(status_of 'agentsText([{ status: "working" }, { status: "blocked" }])')"
}

function test_counts_the_agents_that_need_you() {
  assert_same "· 2 needs you" "$(status_of 'needsText([{ status: "blocked" }, { status: "working" }, { status: "blocked" }])')"
}

function test_says_nothing_of_needs_while_no_agent_is_blocked() {
  assert_same "" "$(status_of 'needsText([{ status: "working" }, { status: "idle" }])')"
}

function test_a_space_on_another_machine_shows_that_machine_as_a_server() {
  assert_same '{"icon":"server","name":"vps"}' "$(status_of 'JSON.stringify(machineLabel({ machine: "vps" }, "exegol"))')"
}

function test_a_space_on_this_computer_shows_its_host_name_as_a_monitor() {
  assert_same '{"icon":"monitor","name":"exegol"}' "$(status_of 'JSON.stringify(machineLabel({ machine: null }, "exegol"))')"
}

function test_this_computer_keeps_the_stock_name_while_the_host_is_not_known() {
  assert_same '{"icon":"monitor","name":"This computer"}' "$(status_of 'JSON.stringify(machineLabel({ machine: null }, ""))')"
}

function test_the_clock_waits_until_the_next_minute_starts() {
  assert_same "17500" "$(status_of 'untilNextMinute(new Date("2026-11-09T07:05:42.500"))')"
}

# Prints the value of $1, a call to the exports of status.js, at local time.
status_of() {
  CALL="$1" STATUS="$STATUS" mise x node@latest -- node --input-type=module -e '
    const status = await import(process.env.STATUS);
    console.log(new Function(...Object.keys(status), `return ${process.env.CALL}`)(...Object.values(status)));
  '
}
