#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROGRAMS="$ROOT/herdr-app/programs.json"
MODS="$ROOT/herdr-app/mods"

function set_up() {
  [[ -f $PROGRAMS ]] || bashunit::fail "missing the file under test: $PROGRAMS"
}

function test_pi_shows_the_icon_that_the_tab_bar_writes_as_a_picture_in_every_mod() {
  assert_same '{"icon":"mods/tab-bar/pi.svg","tint":false}' "$(jq -c '.programs.pi' "$PROGRAMS")"
  assert_contains 'export const PI_ICON = "mods/tab-bar/pi.svg";' "$(cat "$MODS/tab-bar/pi-icon.js")"
}

function test_the_tab_bar_and_the_picker_draw_an_untinted_icon_as_a_picture() {
  assert_contains "g.tint ? svg(g.icon)" "$(cat "$MODS/tab-bar/program-icon.js")"
  assert_contains ": image(g.icon).w(14).h(14)" "$(cat "$MODS/tab-bar/program-icon.js")"
  assert_contains "g.tint ? svg(g.icon)" "$(cat "$MODS/recent-picker/program-icon.js")"
  assert_contains ": image(g.icon).w(14).h(14)" "$(cat "$MODS/recent-picker/program-icon.js")"
}
