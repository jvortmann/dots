#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
LIST="$ROOT/herdr-app/mods/tab-bar/agent-list.js"

function set_up() {
  [[ -f $LIST ]] || bashunit::fail "missing the file under test: $LIST"
}

function test_the_agent_list_sits_on_the_canvas_like_the_recent_picker() {
  assert_contains ".bg(t.canvas)" "$(rows_function)"
  assert_not_contains "t.popover" "$(cat "$LIST")"
}

# The order of the stock sidebar, after the number of alt-N.
function test_a_row_shows_the_number_the_program_icon_the_space_and_tab_the_time_and_the_status_mark() {
  assert_same "number icon place time mark " "$(agent_cells_function | row_parts)"
}

function test_the_name_of_the_program_shows_under_the_pointer_and_to_a_screen_reader() {
  assert_contains ".tooltip(g.name)" "$(icon_function)"
  assert_contains ".accessibility_label(g.name)" "$(icon_function)"
}

# With the name gone, the space and tab are the main text of the row, so they
# brighten with it under the pointer and on the chosen row.
function test_the_space_and_tab_take_the_text_color_of_the_row() {
  assert_contains 'div().flex_1().min_w(0).truncate().child(`${a.space_name} · ${a.tab_name}`)' "$(agent_cells_function)"
}

# The program table of the app gives no icon to a program it does not list.
function test_a_program_with_no_icon_shows_its_name() {
  assert_contains "if (!g.icon) return div().flex_none().max_w(140).truncate().child(g.name);" "$(icon_function)"
}

# A picture, such as the violet pi of programs.json, keeps its own colors.
function test_the_program_icon_draws_a_glyph_in_the_color_of_the_tab_bar_or_a_picture_as_it_is() {
  assert_contains 'import { programGlyph } from "./program-icon.js";' "$(cat "$LIST")"
  assert_contains ".child(programGlyph(t, g))" "$(icon_function)"
}

# 22 px is an icon and its gap, so the type of a child row sits under the
# space of its agent.
function test_a_child_row_shows_an_indent_by_its_depth_the_type_the_description_and_the_status_mark() {
  assert_contains ".children(a.depth ? childCells(t, a) : agentCells(t, a))" "$(row_function)"
  assert_same "indent type description mark " "$(child_cells_function | child_parts)"
}

function test_a_click_on_a_row_goes_to_its_agent_with_a_hand_cursor() {
  assert_contains ".cursor_pointer()" "$(row_function)"
  assert_contains ".on_click(() => go(a))" "$(row_function)"
}

# The 1 px edge takes 1 px of the padding, so the text stays in place.
function test_the_chosen_row_has_the_fill_edge_and_corners_of_the_shown_tab_like_the_picker() {
  assert_contains 'import { alpha } from "./alpha.js";' "$(cat "$LIST")"
  assert_contains "const edge = alpha(t.border, 1 / 4);" "$(row_function)"
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

function test_the_text_takes_the_13_px_size_of_the_picker_and_the_time_the_dim_11_px_of_the_sidebar() {
  assert_contains ".text_size(13)" "$(rows_function)"
  assert_contains "div().flex_none().text_size(11).text_color(t.dim).child(a.time)" "$(agent_cells_function)"
}

# An empty cell would add the gap of the row before the mark.
function test_an_agent_with_no_time_has_no_time_cell() {
  assert_contains "a.time && div().flex_none().text_size(11)" "$(agent_cells_function)"
  assert_contains "].filter(Boolean);" "$(agent_cells_function)"
  assert_same "" "$(grep -oE 'text_size\([0-9.]+\)' "$LIST" | grep -v -e '^text_size(13)$' -e '^text_size(11)$' | tr '\n' ' ')"
}

function test_a_list_with_no_rows_says_why() {
  assert_contains '.when(rows.length === 0, (el) => el.child(' "$(rows_function)"
  assert_contains '.child(empty)' "$(rows_function)"
}

function test_the_search_field_has_the_look_of_the_field_of_the_recent_picker() {
  assert_contains '.child(h_flex().h(FIELD).px(10).gap(8).items_center().rounded(4).border_1().border_color(t.accent).bg(t.background)' "$(head_function | tr -d '\n' | tr -s ' ' | sed 's/( /(/g; s/ \././g')"
  assert_contains '.child(svg("mods/workspace-chrome/search.svg").size(15).text_color(t.dim))' "$(head_function)"
  assert_contains '.child(Input.new(input).flex_1().h_full().text_size(13).text_color(t.foreground))' "$(head_function)"
}

function test_a_tab_for_each_filter_shows_its_name_and_count_and_a_click_picks_it() {
  assert_contains 'import { FILTERS } from "./search.js";' "$(cat "$LIST")"
  assert_contains '.child(h_flex().gap(2).children(FILTERS.map((f) => filterTab(t, f, counts[f], f === filter, pick))))' "$(head_function)"
  assert_contains 'const LABELS = { all: "All", blocked: "Needs you", working: "Working", done: "Done" };' "$(cat "$LIST")"
  assert_contains '.on_click((_e, cx) => pick(f, cx))' "$(filter_tab_function)"
  assert_contains '.child(LABELS[f])' "$(filter_tab_function)"
}

# Like the chosen row, the 1 px edge takes 1 px of the padding.
function test_the_chosen_filter_has_the_fill_and_edge_of_the_chosen_row() {
  assert_contains '.when(chosen, (el) => el.px(5).bg(t.surface).border_1().border_color(alpha(t.border, 1 / 4)).text_color(t.foreground))' "$(filter_tab_function)"
  assert_contains '.text_color(t.muted)' "$(filter_tab_function)"
  assert_contains '.hover((s) => s.text_color(t.foreground))' "$(filter_tab_function)"
}

# A tab that cannot shrink keeps its words on one line. With counts of 99,
# the four tabs fit the 400 px list with these paddings and gaps.
function test_a_filter_tab_takes_the_11_px_of_the_time_and_keeps_its_width() {
  assert_contains '.text_size(11)' "$(filter_tab_function)"
  assert_contains '.flex_none()' "$(filter_tab_function)"
  assert_contains '.px(6)
    .gap(4)' "$(filter_tab_function)"
  assert_contains 'const LIST_WIDTH = 400;' "$(cat "$ROOT/herdr-app/mods/tab-bar/main.js")"
}

# "All 7 (⌥l)". On the active tab the count takes the color of its status, or
# the text color for All. On another tab it is muted, as its name. The key is dim.
function test_a_filter_tab_reads_its_name_its_count_and_its_key_dim() {
  assert_contains 'const KEYS = { all: "(⌥l)", blocked: "(⌥n)", working: "(⌥w)", done: "(⌥d)" };' "$(cat "$LIST")"
  assert_contains '.child(LABELS[f])
    .child(div().when(chosen, (el) => el.text_color(f === "all" ? t.foreground : t[f])).child(String(count)))
    .child(div().text_color(t.dim).child(KEYS[f]));' "$(filter_tab_function)"
}

function filter_tab_function() {
  sed -n '/^function filterTab(/,/^}/p' "$LIST"
}

function head_function() {
  sed -n '/^export function agentHead(/,/^}/p' "$LIST"
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

function icon_function() {
  sed -n '/^function agentIcon(/,/^}/p' "$LIST"
}

function child_cells_function() {
  sed -n '/^function childCells(/,/^}/p' "$LIST"
}

function child_parts() {
  awk '/\.w\(10 \+ 22 \* c\.depth\)/ { print "indent" } /\.bg\(t\[c\.status\]\)/ { print "dot" } /c\.title/ { print "type" } /c\.msg/ { print "description" } /statusMark\(t, c\.status\)/ { print "mark" }' | tr '\n' ' '
}

function row_parts() {
  awk '/a\.number/ { print "number" } /\.bg\(t\[a\.status\]\)/ { print "dot" } /agentIcon\(t, a\)/ { print "icon" } /a\.program\.name/ { print "name" } /a\.space_name/ { print "place" } /a\.time/ { print "time" } /statusWord\(/ { print "word" } /statusMark\(t, a\.status\)/ { print "mark" }' | tr '\n' ' '
}
