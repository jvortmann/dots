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

function test_the_agents_keep_the_order_of_the_app_and_take_their_place_as_their_number() {
  assert_same "t3=1 t1=2 vps/t7=3" "$(status_of 'agentList([{ address: "t3" }, { address: "t1" }, { address: "vps/t7" }]).map((a) => `${a.address}=${a.number}`).join(" ")')"
}

function test_an_agent_after_the_ninth_has_no_number_because_alt_takes_one_digit() {
  assert_same "9 null" "$(status_of 'agentList(Array.from({ length: 10 }, (_, i) => ({ address: `t${i}` }))).slice(8).map((a) => String(a.number)).join(" ")')"
}

function test_a_blocked_agent_reads_needs_you_and_the_other_statuses_read_as_they_are() {
  assert_same "working,needs you,done,idle" "$(status_of '["working", "blocked", "done", "idle"].map(statusWord).join(",")')"
}

function test_the_arrows_move_the_chosen_row_and_stop_at_the_ends_of_the_list() {
  assert_same '{"chosen":1} {"chosen":1} {"chosen":0} {"chosen":0}' "$(status_of '[listKey("down", 0, 2), listKey("down", 1, 2), listKey("up", 1, 2), listKey("up", 0, 2)].map((k) => JSON.stringify(k)).join(" ")')"
}

function test_enter_goes_to_the_chosen_row() {
  assert_same '{"go":1}' "$(status_of 'JSON.stringify(listKey("enter", 1, 2))')"
}

function test_a_digit_goes_to_the_agent_with_that_number_and_a_number_no_agent_holds_does_nothing() {
  assert_same '{"go":1} null' "$(status_of '[listKey("2", 0, 3), listKey("4", 0, 3)].map((k) => JSON.stringify(k)).join(" ")')"
}

function test_keys_on_an_empty_list_do_nothing() {
  assert_same "null null" "$(status_of '[listKey("down", 0, 0), listKey("enter", 0, 0)].map((k) => JSON.stringify(k)).join(" ")')"
}

function test_enter_goes_to_the_last_row_when_the_list_shrank_under_the_chosen_row() {
  assert_same '{"go":1}' "$(status_of 'JSON.stringify(listKey("enter", 3, 2))')"
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
