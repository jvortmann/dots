#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
LAYOUT="$ROOT/herdr-app/layouts/mine.json"
KEYS="$ROOT/herdr-app/keys.json"

function set_up() {
  [[ -f $LAYOUT ]] || bashunit::fail "missing the file under test: $LAYOUT"
}

function test_the_layout_shows_the_theme_of_the_settings() {
  assert_same "" "$(jq -r '.. | objects | .theme // empty' "$LAYOUT")"
}

function test_the_layout_shows_the_font_of_the_settings() {
  assert_same "" "$(jq -r '.. | objects | keys[] | select(startswith("font"))' "$LAYOUT")"
}

function test_the_layout_shows_the_copy_mode_mod_so_that_its_chord_reaches_it() {
  assert_same "copy-mode" "$(jq -r '.. | objects | select(.hidden != true) | .content?.mod? // empty
    | select(. == "copy-mode")' "$LAYOUT")"
}

function test_the_layout_shows_the_window_mod_so_that_it_maximizes_the_window_at_start() {
  assert_same "window" "$(jq -r '.. | objects | select(.hidden != true) | .content?.mod? // empty
    | select(. == "window")' "$LAYOUT")"
}

# A <mod>.<command> key reaches only a mod that the layout shows.
function test_the_layout_shows_the_nav_mod_so_that_ctrl_h_j_k_l_reach_it() {
  assert_same "nav" "$(jq -r '.. | objects | select(.hidden != true) | .content?.mod? // empty
    | select(. == "nav")' "$LAYOUT")"
}

function test_the_tab_bar_shows_below_the_terminals() {
  assert_same "active tab-bar" "$(jq -r '.. | objects | select(.type? == "column") | .children
    | map(if any(.. | objects; .content?.tab? == "active") then "active"
      elif any(.. | objects; .content?.mod? == "tab-bar") then "tab-bar" else empty end)
    | select(length == 2) | join(" ")' "$LAYOUT")"
}

function test_the_panes_show_no_header() {
  assert_same "" "$(jq -c '.. | objects | .pane?.header? // empty' "$LAYOUT")"
}

function test_the_terminals_sit_4_px_inside_the_work_area_with_no_gaps() {
  assert_same "4 4 0 0" "$(jq -r '.children[] | select(.id == "work")
    | [.padding[], .gap, (.. | objects | .pane?.gap? // empty)] | join(" ")' "$LAYOUT")"
}

function test_the_panes_have_square_corners() {
  assert_same "0" "$(jq -r '.. | objects | .pane?.radius? | select(. != null)' "$LAYOUT")"
}

function test_the_sidebar_that_cmd_b_shows_starts_hidden() {
  local sidebar
  sidebar="$(jq -r '.global["cmd-b"] | ltrimstr("layout.toggle:")' "$KEYS")"
  assert_same "true" "$(jq -r --arg id "$sidebar" '.. | objects | select(.id? == $id) | .hidden' "$LAYOUT")"
}

# The tab bar shows and hides the panel by these ids, as the stock tabs mod does.
function test_the_changes_panel_of_the_stock_layout_starts_hidden_beside_the_terminals() {
  assert_same "main panel" "$(jq -r '.. | objects | select(.type? == "row") | .children | map(.id)
    | select(index("panel")) | join(" ")' "$LAYOUT")"
  assert_same "true panel-body changes changes" "$(jq -r '.. | objects | select(.id? == "panel")
    | [.hidden, (.children[] | .id, .active, (.children[] | .content.mod))] | join(" ")' "$LAYOUT")"
}

function test_the_macos_window_buttons_sit_out_of_view() {
  assert_same "-100 -100" "$(jq -r '.traffic_lights | join(" ")' "$LAYOUT")"
}

function test_the_bottom_bar_moves_the_window_while_the_sidebar_is_hidden() {
  assert_same "tab-bar" "$(jq -r 'def shown: select(.hidden != true) | ., (.children[]? | shown);
    [shown | select(.window_drag == true) | .content?.mod? // empty] | join(" ")' "$LAYOUT")"
}

function test_the_layout_colors_follow_the_theme_in_both_appearances() {
  assert_same "" "$(jq -r '.. | strings | select(startswith("#"))' "$LAYOUT")"
}
