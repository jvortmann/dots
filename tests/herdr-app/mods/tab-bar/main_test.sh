#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
MAIN="$ROOT/herdr-app/mods/tab-bar/main.js"

function set_up() {
  [[ -f $MAIN ]] || bashunit::fail "missing the file under test: $MAIN"
}

function test_the_tab_bar_colors_follow_the_theme_in_both_appearances() {
  assert_same "" "$(grep -oE '#[0-9a-fA-F]{3,8}\b|rgba?\(' "$MAIN" | tr '\n' ' ')"
}
