#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROGRAMS="$ROOT/herdr-app/programs.json"
PI="$ROOT/herdr-app/my-icons/pi.svg"
STOCK_PI="$ROOT/herdr-app/icons/pi.svg"
MODS="$ROOT/herdr-app/mods"

function set_up() {
  [[ -f $PROGRAMS ]] || bashunit::fail "missing the file under test: $PROGRAMS"
}

function test_pi_shows_our_own_icon_as_a_picture_in_every_mod() {
  assert_same '{"icon":"my-icons/pi.svg","tint":false}' "$(jq -c '.programs.pi' "$PROGRAMS")"
}

function test_the_tab_bar_and_the_picker_draw_an_untinted_icon_as_a_picture() {
  assert_contains "g.tint ? svg(g.icon)" "$(cat "$MODS/tab-bar/program-icon.js")"
  assert_contains ": image(g.icon).w(14).h(14)" "$(cat "$MODS/tab-bar/program-icon.js")"
  assert_contains "g.tint ? svg(g.icon)" "$(cat "$MODS/recent-picker/program-icon.js")"
  assert_contains ": image(g.icon).w(14).h(14)" "$(cat "$MODS/recent-picker/program-icon.js")"
}

function test_our_pi_icon_is_the_shape_of_the_stock_one_filled_with_solarized_violet() {
  assert_same 'fill="#6c71c4" fill="#6c71c4" ' "$(grep -oE 'fill="[^"]*"' "$PI" 2>&1 | tr '\n' ' ')"
  if [[ ! -f $STOCK_PI ]]; then
    bashunit::skip "the app has not written its icons yet" && return
  fi
  assert_same "$(cat "$STOCK_PI")" "$(sed 's/#6c71c4/#fff/g' "$PI" 2>&1)"
}
