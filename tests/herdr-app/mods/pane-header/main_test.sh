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
