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

function test_the_appearance_follows_the_system_or_is_fixed_to_light_or_dark() {
  assert_matches '^(null|"light"|"dark")$' "$(jq -c '.appearance' "$SETTINGS")"
}
