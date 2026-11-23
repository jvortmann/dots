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

# A child row takes the address of its agent, so that a click on it goes to
# that agent. It has no number, because alt-N goes to agents only.
function test_the_records_of_an_agent_follow_it_as_child_rows_with_no_number() {
  assert_same "t3=1 t3=-,1,working,Explore,find a t1=2" "$(status_of 'agentList([{ address: "t3" }, { address: "t1" }], { t3: { "sub/a": { state: "working", title: "Explore", msg: "find a" } } }).map((r) => `${r.address}=${r.number ?? "-"}` + (r.depth ? `,${r.depth},${r.status},${r.title},${r.msg}` : "")).join(" ")')"
}

# In OSC 7501, the record sub/a/c is a child of the record sub/a.
function test_a_child_record_follows_its_parent_record_one_level_deeper() {
  assert_same "a1 c2 b1" "$(status_of 'agentList([{ address: "t3" }], { t3: { "sub/b": { title: "b" }, "sub/a/c": { title: "c" }, "sub/a": { title: "a" } } }).slice(1).map((r) => `${r.title}${r.depth}`).join(" ")')"
}

function test_each_row_has_a_key_of_its_own() {
  assert_same "t3 t3:sub/a t3:sub/a/c" "$(status_of 'agentList([{ address: "t3" }], { t3: { "sub/a": {}, "sub/a/c": {} } }).map((r) => r.key).join(" ")')"
}

function test_the_arrows_move_the_chosen_row_and_stop_at_the_ends_of_the_list() {
  assert_same '{"chosen":1} {"chosen":1} {"chosen":0} {"chosen":0}' "$(status_of '[listKey("down", 0, [{}, {}]), listKey("down", 1, [{}, {}]), listKey("up", 1, [{}, {}]), listKey("up", 0, [{}, {}])].map((k) => JSON.stringify(k)).join(" ")')"
}

# The search takes j and k as text.
function test_ctrl_j_and_ctrl_k_move_the_chosen_row_and_j_and_k_do_not() {
  assert_same '{"chosen":1} {"chosen":0} null null' "$(status_of '[listKey("ctrl-j", 0, [{}, {}]), listKey("ctrl-k", 1, [{}, {}]), listKey("j", 0, [{}, {}]), listKey("k", 1, [{}, {}])].map((k) => JSON.stringify(k)).join(" ")')"
}

function test_enter_goes_to_the_chosen_row() {
  assert_same '{"go":1}' "$(status_of 'JSON.stringify(listKey("enter", 1, [{}, {}]))')"
}

# The search takes a digit as text. alt-N goes to agent N from anywhere.
function test_a_digit_in_the_list_is_text_for_the_search() {
  assert_same "null" "$(status_of 'JSON.stringify(listKey("2", 0, [{ number: 1 }, { number: 2 }]))')"
}

# A filter can leave no rows, and the next one must stay in reach.
function test_tab_and_shift_tab_go_to_the_next_and_the_previous_filter_also_on_an_empty_list() {
  assert_same '{"filter":1} {"filter":-1}' "$(status_of '[listKey("tab", 0, []), listKey("shift-tab", 0, [{}])].map((k) => JSON.stringify(k)).join(" ")')"
}

function test_escape_asks_to_clear_the_search_or_close_also_on_an_empty_list() {
  assert_same '{"escape":true}' "$(status_of 'JSON.stringify(listKey("escape", 0, []))')"
}

function test_keys_on_an_empty_list_do_nothing() {
  assert_same "null null" "$(status_of '[listKey("down", 0, []), listKey("enter", 0, [])].map((k) => JSON.stringify(k)).join(" ")')"
}

function test_enter_goes_to_the_last_row_when_the_list_shrank_under_the_chosen_row() {
  assert_same '{"go":1}' "$(status_of 'JSON.stringify(listKey("enter", 3, [{}, {}]))')"
}

function test_the_clock_waits_until_the_next_minute_starts() {
  assert_same "17500" "$(status_of 'untilNextMinute(new Date("2026-11-09T07:05:42.500"))')"
}

function test_an_agent_seen_first_is_stamped_with_its_state_and_the_time() {
  assert_same '{"t1":{"s":"working","at":5}}' "$(status_of 'JSON.stringify(stampChanges({}, [{ address: "t1", status: "working" }], 5))')"
}

function test_an_agent_that_keeps_its_state_keeps_its_stamp() {
  assert_same '{"t1":{"s":"working","at":5}}' "$(status_of 'JSON.stringify(stampChanges({ t1: { s: "working", at: 5 } }, [{ address: "t1", status: "working" }], 9))')"
}

# A look at a done agent turns it idle, and a look is not the agent doing
# anything. The stock sidebar counts the two as one state for this reason.
function test_an_agent_that_goes_from_done_to_idle_keeps_its_stamp() {
  assert_same '{"t1":{"s":"idle","at":5}}' "$(status_of 'JSON.stringify(stampChanges(stampChanges({}, [{ address: "t1", status: "done" }], 5), [{ address: "t1", status: "idle" }], 9))')"
}

function test_an_agent_that_changes_its_state_is_stamped_again() {
  assert_same '{"t1":{"s":"blocked","at":9}}' "$(status_of 'JSON.stringify(stampChanges({ t1: { s: "working", at: 5 } }, [{ address: "t1", status: "blocked" }], 9))')"
}

# The list is empty right after a start, so only age makes a stamp go.
function test_the_stamp_of_an_agent_that_is_gone_goes_after_30_days() {
  assert_same '{"new":{"s":"idle","at":2592000001}}' "$(status_of 'JSON.stringify(stampChanges({ old: { s: "idle", at: 0 }, new: { s: "idle", at: 2592000001 } }, [], 2592000002))')"
}

function test_an_agent_still_listed_keeps_a_stamp_older_than_30_days() {
  assert_same '{"t1":{"s":"idle","at":0}}' "$(status_of 'JSON.stringify(stampChanges({ t1: { s: "idle", at: 0 } }, [{ address: "t1", status: "idle" }], 2592000002))')"
}

function test_an_agent_row_shows_the_time_since_its_last_change_as_the_sidebar_does() {
  assert_same "<1m 5m 2h 3d" "$(status_of 'agentList(["a", "b", "c", "d"].map((address) => ({ address })), {}, { a: { at: 9e9 - 59999 }, b: { at: 9e9 - 5 * 60000 }, c: { at: 9e9 - 150 * 60000 }, d: { at: 9e9 - 80 * 3600000 } }, 9e9).map((a) => a.time).join(" ")')"
}

function test_an_agent_row_with_no_stamp_shows_no_time() {
  assert_same "" "$(status_of 'agentList([{ address: "a" }], {}, {}, 9e9)[0].time')"
}

# A subagent reports to its agent, so its done is no news, as in the stock
# sidebar.
function test_a_child_record_in_error_reads_as_blocked_and_a_done_one_as_idle() {
  assert_same "blocked idle working" "$(status_of 'agentList([{ address: "t3" }], { t3: { "sub/a": { state: "error" }, "sub/b": { state: "done" }, "sub/c": { state: "working" } } }).slice(1).map((r) => r.status).join(" ")')"
}

function test_the_agents_come_by_focus_recency_and_the_agents_never_focused_last_in_tab_order() {
  assert_same "t3 t1 t2 t4" "$(status_of 'agentList(["t1", "t2", "t3", "t4"].map((address) => ({ address })), {}, {}, 0, ["t3", "t1"]).map((a) => a.address).join(" ")')"
}

# alt-N goes to agent N in tab order, so the number of a row does not move
# with the focus.
function test_an_agent_keeps_the_number_of_its_place_in_tab_order_in_the_recency_order() {
  assert_same "t3=3 t1=1 t2=2 t4=4" "$(status_of 'agentList(["t1", "t2", "t3", "t4"].map((address) => ({ address })), {}, {}, 0, ["t3", "t1"]).map((a) => `${a.address}=${a.number}`).join(" ")')"
}

function test_the_child_rows_of_an_agent_follow_it_in_the_recency_order() {
  assert_same "t3 t3:sub/a t1 t2" "$(status_of 'agentList([{ address: "t1" }, { address: "t2" }, { address: "t3" }], { t3: { "sub/a": {} } }, {}, 0, ["t3", "t1"]).map((r) => r.key).join(" ")')"
}

# So alt-a and then enter goes back to the agent before, as the recent picker
# does with the space before.
function test_the_list_opens_on_the_agent_focused_before_the_focused_agent() {
  assert_same "2" "$(status_of 'openingRow([{ address: "t1", focused: true }, { depth: 1 }, { address: "t2" }])')"
}

# With the focus on a pane with no agent, the agent focused last is the one
# before.
function test_the_list_opens_on_the_first_agent_while_no_agent_has_the_focus() {
  assert_same "0" "$(status_of 'openingRow([{ address: "t1" }, { address: "t2" }])')"
}

function test_the_list_opens_on_the_focused_agent_when_it_is_the_only_agent() {
  assert_same "0" "$(status_of 'openingRow([{ address: "t1", focused: true }, { depth: 1 }])')"
}

# Prints the value of $1, a call to the exports of status.js, at local time.
status_of() {
  CALL="$1" STATUS="$STATUS" mise x node@latest -- node --input-type=module -e '
    const status = await import(process.env.STATUS);
    console.log(new Function(...Object.keys(status), `return ${process.env.CALL}`)(...Object.values(status)));
  '
}
