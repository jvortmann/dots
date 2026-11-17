#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
KEYS="$ROOT/herdr-app/keys.json"

function set_up() {
  [[ -f $KEYS ]] || bashunit::fail "missing the file under test: $KEYS"
}

function test_ctrl_h_j_k_l_in_a_terminal_go_to_the_pane_left_down_up_and_right() {
  assert_same "pane.go:left pane.go:down pane.go:up pane.go:right" \
    "$(jq -r '.terminal | [."ctrl-h", ."ctrl-j", ."ctrl-k", ."ctrl-l"] | join(" ")' "$KEYS")"
}

function test_leaves_ctrl_and_a_digit_to_the_macos_spaces() {
  assert_same "" "$(jq -r '[.[] | keys[] | select(test("^ctrl-[0-9]$"))] | join(" ")' "$KEYS")"
}
