#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
KEYS="$ROOT/herdr-app/keys.json"

function set_up() {
  [[ -f $KEYS ]] || bashunit::fail "missing the file under test: $KEYS"
}

function test_leaves_ctrl_and_a_digit_to_the_macos_spaces() {
  assert_same "" "$(jq -r '[.[] | keys[] | select(test("^ctrl-[0-9]$"))] | join(" ")' "$KEYS")"
}
