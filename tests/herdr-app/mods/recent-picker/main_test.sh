#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
MAIN="$ROOT/herdr-app/mods/recent-picker/main.js"
ICON="$ROOT/herdr-app/mods/recent-picker/program-icon.js"
MOD="$ROOT/herdr-app/mods/recent-picker/mod.json"

function set_up() {
  [[ -f $MAIN ]] || bashunit::fail "missing the file under test: $MAIN"
}

function test_the_picker_lists_the_spaces_in_the_order_that_the_tab_bar_records() {
  assert_contains 'const RECENT = "tab-bar.space-history";' "$(grep -F 'const RECENT' "$MAIN")"
  assert_contains "recentSpaces(spaces(), shared(RECENT) ?? []).map(" "$(rows_method)"
}

function test_no_status_sort_or_fold_for_quiet_spaces_moves_a_space_out_of_its_recency_place() {
  assert_same "" "$(grep -vE '^ *//' "$MAIN" | grep -oE 'earlier|showEarlier|\.sort\(' | tr '\n' ' ')"
}

function test_the_picker_opens_on_the_row_of_the_tab_that_the_previous_space_showed_last() {
  assert_contains 'if (this.at === null) {' "$(render_method)"
  assert_contains 'const tab = openingTab(spaces(), shared(RECENT) ?? []);' "$(render_method)"
  assert_contains 'this.at = Math.max(0, pickable.findIndex((r) => r.kind === "ctx" && r.ctx.id === tab));' "$(render_method)"
}

function test_the_picker_sits_on_the_canvas_like_the_tabs_that_are_not_shown() {
  assert_contains ".bg(t.canvas)" "$(picker_box)"
}

function test_the_chosen_row_has_the_fill_edge_and_corners_of_the_shown_tab() {
  assert_contains 'const edge = quarter(t.border);' "$(render_method)"
  assert_same "2" "$(grep -cF '.when(on, (el) => el.px(9).bg(t.surface).border_1().border_color(edge).text_color(t.foreground))' "$MAIN")"
  assert_same "" "$(grep -oE '\.rounded\([0-9]+\)' "$MAIN" | grep -v '^\.rounded(4)$' | tr '\n' ' ')"
}

function test_a_row_not_chosen_has_no_fill_and_its_text_brightens_under_the_pointer_like_a_tab() {
  assert_same "" "$(grep -oE 't\.hover' "$MAIN" | tr '\n' ' ')"
  assert_same "3" "$(grep -cF '.hover((s) => s.text_color(t.foreground))' "$MAIN")"
  assert_contains ".text_color(t.muted)" "$(tab_row)"
  assert_contains ".child(div().flex_1().truncate().when(here," "$(tab_row)"
}

function test_the_rows_draw_their_icons_like_the_tab_bar_and_no_text_glyph_stands_in_for_one() {
  assert_same "" "$(grep -oE '"[○●·+]"' "$MAIN" | tr '\n' ' ')"
  assert_contains 'svg("mods/tab-bar/stack.svg").size(15).text_color(spaceColor(t, r.w))' "$(sed -n '/r\.kind === "head"/,/;$/p' "$MAIN")"
  assert_contains 'svg("mods/workspace-chrome/plus.svg").size(14)' "$(cat "$MAIN")"
}

function test_the_program_icon_is_14_px_with_the_status_dot_of_the_tab_bar() {
  assert_contains "svg(g.icon).size(14)" "$(icon_function)"
  assert_contains "image(g.icon).w(14).h(14)" "$(icon_function)"
  assert_contains "div().absolute().top(-2).right(-2).w(7).h(7).rounded_full().bg(dot)" "$(icon_function)"
}

function test_all_text_takes_the_13_px_size_of_the_tab_bar() {
  assert_same "" "$(grep -oE 'text_size\([0-9.]+\)' "$MAIN" | grep -v '^text_size(13)$' | tr '\n' ' ')"
}

function test_the_picker_drops_from_the_top_at_the_size_of_the_stock_picker() {
  assert_same '"none" {"kind":"popup","at":"top","offset":40,"width":640,"height":0.8}' "$(jq -c '.place, .overlay' "$MOD" | tr '\n' ' ' | sed 's/ $//')"
}

function test_the_picker_names_the_stock_mod_and_version_it_was_copied_from() {
  assert_same '{"name":"picker","version":"0.1.16"}' "$(jq -c '.cloned_from' "$MOD")"
}

function test_a_program_glyph_takes_the_color_that_stands_out_on_the_canvas_as_in_the_tab_bar() {
  assert_contains 'import { programIcon } from "./program-icon.js";' "$(cat "$MAIN")"
  assert_contains 'import { glyphColor } from "./glyph.js";' "$(icon_function)"
  assert_contains "svg(g.icon).size(14).text_color(glyphColor(g, t.canvas, t.foreground, t))" "$(icon_function)"
}

function test_the_glyph_rule_of_the_picker_is_the_same_as_the_tab_bar_s() {
  assert_same "" "$(diff "$ROOT/herdr-app/mods/tab-bar/glyph.js" "$ROOT/herdr-app/mods/recent-picker/glyph.js" 2>&1)"
}

function test_the_program_icon_of_the_picker_is_the_same_as_the_tab_bar_s() {
  assert_same "" "$(diff "$ROOT/herdr-app/mods/tab-bar/program-icon.js" "$ROOT/herdr-app/mods/recent-picker/program-icon.js" 2>&1)"
}

function test_the_lead_pane_rule_of_the_picker_is_the_same_as_the_tab_bar_s() {
  assert_same "" "$(diff "$ROOT/herdr-app/mods/tab-bar/lead.js" "$ROOT/herdr-app/mods/recent-picker/lead.js" 2>&1)"
}

function test_a_tab_row_shows_the_icon_and_dot_of_the_lead_pane_of_the_tab_like_the_tab_bar() {
  assert_contains 'import { lead } from "./lead.js";' "$(cat "$MAIN")"
  assert_contains "const shown = panes();" "$(rows_method)"
  assert_contains "lead: lead(shown, ctx.id)" "$(rows_method)"
  assert_contains ".child(programIcon(t, r.lead, r.lead?.status))" "$(tab_row)"
}

function icon_function() {
  cat "$ICON"
}

function tab_row() {
  sed -n '/\.id(`pk-${r\.ctx\.id}`)/,/;$/p' "$MAIN"
}

function picker_box() {
  sed -n '/^    return v_flex()$/,/\.on_key_down(/p' "$MAIN"
}

function render_method() {
  sed -n '/^  render(/,/^  }/p' "$MAIN"
}

function rows_method() {
  sed -n '/^  rows(/,/^  }/p' "$MAIN"
}
