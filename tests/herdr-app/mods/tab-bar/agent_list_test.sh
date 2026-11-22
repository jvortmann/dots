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

function test_the_agent_list_sits_on_the_canvas_like_the_recent_picker() {
  assert_contains ".bg(t.canvas)" "$(rows_function)"
  assert_not_contains "t.popover" "$(cat "$LIST")"
}

# The mod loader rejects an import from another mod folder, so each mod keeps
# a copy.
function test_the_edge_rule_of_the_list_is_the_same_as_the_picker_s() {
  assert_same "" "$(diff "$ROOT/herdr-app/mods/recent-picker/edge.js" "$ROOT/herdr-app/mods/tab-bar/edge.js" 2>&1)"
}

function test_a_row_shows_the_number_the_status_dot_the_name_the_space_and_tab_and_the_status() {
  assert_same "number dot name place status " "$(agent_cells_function | row_parts)"
}

# 14 px is a dot and its gap, so the dot of a child row sits under the name of
# its parent.
function test_a_child_row_shows_an_indent_by_its_depth_the_status_dot_the_type_and_the_description() {
  assert_contains ".children(a.depth ? childCells(t, a) : agentCells(t, a))" "$(row_function)"
  assert_same "indent dot type description " "$(child_cells_function | child_parts)"
}

function test_a_click_on_a_row_goes_to_its_agent_with_a_hand_cursor() {
  assert_contains ".cursor_pointer()" "$(row_function)"
  assert_contains ".on_click(() => go(a))" "$(row_function)"
}

# The 1 px edge takes 1 px of the padding, so the text stays in place.
function test_the_chosen_row_has_the_fill_edge_and_corners_of_the_shown_tab_like_the_picker() {
  assert_contains 'import { quarter } from "./edge.js";' "$(cat "$LIST")"
  assert_contains "const edge = quarter(t.border);" "$(row_function)"
  assert_contains ".when(chosen, (el) => el.px(7).bg(t.surface).border_1().border_color(edge).text_color(t.foreground))" "$(row_function)"
  assert_contains "rows.map((a, i) => row(t, a, i === chosen, go))" "$(rows_function)"
  assert_same "" "$(grep -oE '\.rounded\([0-9]+\)' "$LIST" | grep -v -e '^\.rounded(4)$' -e '^\.rounded(3)$' | tr '\n' ' ')"
}

function test_a_row_not_chosen_has_no_fill_and_its_text_brightens_under_the_pointer_like_the_picker() {
  assert_same "" "$(grep -oE 's\.bg\(' "$LIST" | tr '\n' ' ')"
  assert_contains ".text_color(t.muted)" "$(row_function)"
  assert_contains ".hover((s) => s.text_color(t.foreground))" "$(row_function)"
  assert_same "" "$({ agent_cells_function; child_cells_function; } | grep -oE 't\.muted' | tr '\n' ' ')"
}

function test_all_text_takes_the_13_px_size_of_the_picker() {
  assert_contains ".text_size(13)" "$(rows_function)"
  assert_same "" "$(grep -oE 'text_size\([0-9.]+\)' "$LIST" | grep -v '^text_size(13)$' | tr '\n' ' ')"
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

function agent_cells_function() {
  sed -n '/^function agentCells(/,/^}/p' "$LIST"
}

function child_cells_function() {
  sed -n '/^function childCells(/,/^}/p' "$LIST"
}

function child_parts() {
  awk '/\.w\(10 \+ 14 \* c\.depth\)/ { print "indent" } /\.bg\(t\[c\.status\]\)/ { print "dot" } /c\.title/ { print "type" } /c\.msg/ { print "description" }' | tr '\n' ' '
}

function row_parts() {
  awk '/a\.number/ { print "number" } /\.bg\(t\[a\.status\]\)/ { print "dot" } /a\.program\.name/ { print "name" } /a\.space_name/ { print "place" } /statusWord\(a\.status\)/ { print "status" }' | tr '\n' ' '
}
