#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
LIST="$ROOT/herdr-app/mods/tab-bar/agent-list.js"
# shellcheck source=../fixed_colors.sh
source "$ROOT/tests/herdr-app/mods/fixed_colors.sh"

function set_up() {
  [[ -f $LIST ]] || bashunit::fail "missing the file under test: $LIST"
}

function test_the_agent_list_colors_follow_the_theme_in_both_appearances() {
  assert_same "" "$(fixed_colors "$LIST")"
}

function test_a_row_shows_the_number_the_status_dot_the_name_the_space_and_tab_and_the_status() {
  assert_same "number dot name place status " "$(row_function | row_parts)"
}

function test_a_click_on_a_row_goes_to_its_agent_with_a_hand_cursor() {
  assert_contains ".cursor_pointer()" "$(row_function)"
  assert_contains ".on_click(() => go(a))" "$(row_function)"
}

function test_the_chosen_row_and_the_row_under_the_pointer_take_the_selected_fill() {
  assert_contains ".when(chosen, (el) => el.bg(t.selected))" "$(row_function)"
  assert_contains ".hover((s) => s.bg(t.selected))" "$(row_function)"
  assert_contains "rows.map((a, i) => row(t, a, i === chosen, go))" "$(sed -n '/^export function agentRows(/,/^}/p' "$LIST")"
}

function test_a_list_with_no_agents_says_so() {
  assert_contains '.when(rows.length === 0, (el) => el.child(' "$(rows_function)"
  assert_contains '"No agents"' "$(rows_function)"
}

function rows_function() {
  sed -n '/^export function agentRows(/,/^}/p' "$LIST"
}

function row_function() {
  sed -n '/^function row(/,/^}/p' "$LIST"
}

function row_parts() {
  awk '/a\.number/ { print "number" } /\.bg\(t\[a\.status\]\)/ { print "dot" } /a\.program\.name/ { print "name" } /a\.space_name/ { print "place" } /statusWord\(a\.status\)/ { print "status" }' | tr '\n' ' '
}
