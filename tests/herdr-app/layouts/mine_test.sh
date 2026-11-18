#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
LAYOUT="$ROOT/herdr-app/layouts/mine.json"

function set_up() {
  [[ -f $LAYOUT ]] || bashunit::fail "missing the file under test: $LAYOUT"
}

function test_the_layout_shows_the_theme_of_the_settings() {
  assert_same "" "$(jq -r '.. | objects | .theme // empty' "$LAYOUT")"
}

function test_the_layout_shows_the_copy_mode_mod_so_that_its_chord_reaches_it() {
  assert_same "copy-mode" "$(jq -r '.. | objects | select(.hidden != true) | .content?.mod? // empty
    | select(. == "copy-mode")' "$LAYOUT")"
}

function test_the_layout_colors_follow_the_theme_in_both_appearances() {
  assert_same "" "$(jq -r '.. | strings | select(startswith("#"))' "$LAYOUT")"
}
