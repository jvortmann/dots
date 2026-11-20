#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
MAIN="$ROOT/herdr-app/mods/tab-bar/main.js"
# shellcheck source=../fixed_colors.sh
source "$ROOT/tests/herdr-app/mods/fixed_colors.sh"

function set_up() {
  [[ -f $MAIN ]] || bashunit::fail "missing the file under test: $MAIN"
}

function test_the_tab_bar_colors_follow_the_theme_in_both_appearances() {
  assert_same "" "$(fixed_colors "$MAIN")"
}

function test_a_tab_takes_the_width_of_its_label_up_to_a_cap() {
  assert_same "" "$(tab_chain | grep -oE '\.w\([0-9]+\)')"
  assert_contains ".max_w(" "$(tab_chain)"
}

function test_the_tabs_the_tray_and_the_space_chip_have_corners_of_at_most_2_px() {
  assert_contains ".rounded(" "$(space_and_tray_chain)"
  assert_same "" "$({ tab_chain; space_and_tray_chain; } | round_corners_over 2)"
}

function test_the_program_icon_is_at_most_18_px() {
  assert_contains "function tile(" "$(tile_function)"
  assert_same "" "$(tile_function | sizes_over 18)"
}

function tab_chain() {
  sed -n '/const tab = (c) =>/,/\.child(tile/p' "$MAIN"
}

function space_and_tray_chain() {
  sed -n '/\.id("tm-space")/,/\.children(space\.tabs\.map(tab))/p' "$MAIN"
}

function tile_function() {
  sed -n '/^function tile(/,/^}/p' "$MAIN"
}

function round_corners_over() {
  grep -oE '\.rounded(_full\(\)|\([0-9]+\))' | awk -v max="$1" -F'[()]' '$1 ~ /_full$/ || $2 > max' | tr '\n' ' '
}

function sizes_over() {
  grep -oE '\.(w|h|size)\([0-9]+\)' | awk -v max="$1" -F'[()]' '$2 > max' | tr '\n' ' '
}
