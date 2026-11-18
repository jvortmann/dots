#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
LAYOUT="$ROOT/herdr-app/layouts/mine.json"

function set_up() {
  [[ -f $LAYOUT ]] || bashunit::fail "missing the file under test: $LAYOUT"
}

function test_the_layout_shows_the_theme_of_the_settings() {
  assert_same "" "$(jq -r '.. | objects | .theme // empty' "$LAYOUT")"
}

function test_the_layout_colors_follow_the_theme_in_both_appearances() {
  assert_same "" "$(jq -r '.. | strings | select(startswith("#"))' "$LAYOUT")"
}
