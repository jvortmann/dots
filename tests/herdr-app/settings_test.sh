#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SETTINGS="$ROOT/herdr-app/settings.json"

function set_up() {
  [[ -f $SETTINGS ]] || bashunit::fail "missing the file under test: $SETTINGS"
}

function test_the_system_appearance_picks_the_solarized_light_or_dark_theme() {
  assert_same '{"light":"solarized-light","dark":"solarized-dark"}' \
    "$(jq -c '.theme' "$SETTINGS")"
}

function test_the_appearance_is_fixed_to_light_or_dark_in_the_form_swap_theme_edits() {
  assert_same "1" "$(grep -cE '^  "appearance": "(light|dark)",?$' "$SETTINGS")"
}
