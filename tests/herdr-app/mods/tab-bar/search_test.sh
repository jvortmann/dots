#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
SEARCH="$ROOT/herdr-app/mods/tab-bar/search.js"

# Rows as agentList gives them: each agent, then its child rows.
ROWS='[
  { key: "t1", address: "t1", status: "blocked", space_name: "dots", tab_name: "api", program: { name: "Claude" }, title: "Fix login" },
  { key: "t1:sub/a", address: "t1", depth: 1, status: "working", title: "Explore", msg: "find the router" },
  { key: "t2", address: "t2", status: "working", space_name: "web", tab_name: "ui", program: { name: "pi" }, title: "Style the bar" },
  { key: "t3", address: "t3", status: "idle", space_name: "notes", tab_name: "2", program: { name: "Codex" }, title: "" },
  { key: "t4", address: "t4", status: "done", space_name: "dots", tab_name: "docs", program: { name: "pi" }, title: "Write the plan" }
]'

function set_up() {
  [[ -f $SEARCH ]] || bashunit::fail "missing the file under test: $SEARCH"
}

function test_the_needs_you_filter_keeps_only_the_agents_that_need_you() {
  assert_same "t1 t1:sub/a" "$(keys_of 'filterRows(rows, "blocked", "")')"
}

function test_all_shows_every_row_and_the_idle_agents_too() {
  assert_same "t1 t1:sub/a t2 t3 t4" "$(keys_of 'filterRows(rows, "all", "")')"
}

function test_a_child_row_goes_with_the_status_of_its_agent_and_not_its_own() {
  assert_same "t2" "$(keys_of 'filterRows(rows, "working", "")')"
}

function test_the_search_matches_the_space_the_tab_the_program_and_the_title_in_any_case() {
  assert_same "t3|t2|t3|t4" "$(search_of '["notes", "UI", "codex", "Plan"].map((q) => filterRows(rows, "all", q).map((r) => r.key).join(" ")).join("|")')"
}

function test_a_match_on_the_type_or_description_of_a_child_row_keeps_its_agent_shown() {
  assert_same "t1 t1:sub/a|t1 t1:sub/a" "$(search_of '["explore", "router"].map((q) => filterRows(rows, "all", q).map((r) => r.key).join(" ")).join("|")')"
}

# The counts follow the search, so a tab says where the matches are.
function test_each_filter_counts_its_agents_that_match_the_search() {
  assert_same "4 1 1 1|2 1 0 1" "$(search_of '["", "dots"].map((q) => { const c = filterCounts(rows, q); return [c.all, c.blocked, c.working, c.done].join(" "); }).join("|")')"
}

function test_the_next_filter_goes_round_both_ways() {
  assert_same "blocked done all" "$(search_of '[nextFilter("all", 1), nextFilter("all", -1), nextFilter("done", 1)].join(" ")')"
}

function test_the_chosen_row_is_the_agent_chosen_at_the_start_while_it_shows_or_else_the_first() {
  assert_same "2 0" "$(search_of '[rowOf(filterRows(rows, "all", ""), "t2"), rowOf(filterRows(rows, "blocked", ""), "t2")].join(" ")')"
}

function test_the_key_of_a_filter_picks_it_and_the_key_of_the_active_filter_goes_back_to_all() {
  assert_same "done all all" "$(search_of '[pickedFilter("all", "done"), pickedFilter("done", "done"), pickedFilter("all", "all")].join(" ")')"
}

function test_a_filter_command_names_its_filter_and_another_command_names_none() {
  assert_same "done blocked null null" "$(search_of '[filterOfCommand("filter-done"), filterOfCommand("filter-blocked"), filterOfCommand("filter-idle"), filterOfCommand("swap-left")].map(String).join(" ")')"
}

# Prints the keys of the rows that $1, a call to the exports of search.js
# with the rows above as rows, gives.
keys_of() {
  search_of "$1.map((r) => r.key).join(\" \")"
}

# Prints the value of $1, a call to the exports of search.js with the rows
# above as rows.
search_of() {
  CALL="$1" ROWS="$ROWS" SEARCH="$SEARCH" mise x node@latest -- node --input-type=module -e '
    const search = await import(process.env.SEARCH);
    const rows = new Function(`return ${process.env.ROWS}`)();
    console.log(new Function("rows", ...Object.keys(search), `return ${process.env.CALL}`)(rows, ...Object.values(search)));
  ' 2>&1
}
