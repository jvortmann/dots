#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
MAIN="$ROOT/herdr-app/mods/pane-header/main.js"
# shellcheck source=../fixed_colors.sh
source "$ROOT/tests/herdr-app/mods/fixed_colors.sh"

function set_up() {
  [[ -f $MAIN ]] || bashunit::fail "missing the file under test: $MAIN"
}

function test_the_pane_header_colors_follow_the_theme_in_both_appearances() {
  assert_same "" "$(fixed_colors "$MAIN")"
}

function test_the_name_stays_centered_as_the_left_side_is_as_wide_as_the_buttons_on_the_right() {
  assert_contains ".child(div().flex_1().min_w(BUTTONS_WIDTH))" "$(cat "$MAIN")"
  assert_same "$(grep -c 'this\.button(t,' "$MAIN")" "$(sed -nE 's/^const BUTTONS_WIDTH = ([0-9]+) \*.*/\1/p' "$MAIN")"
}
