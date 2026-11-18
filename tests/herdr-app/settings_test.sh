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

function test_no_fixed_appearance_overrides_the_system_appearance() {
  assert_same "null" "$(jq -c '.appearance' "$SETTINGS")"
}
