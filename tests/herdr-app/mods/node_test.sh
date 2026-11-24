#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

# The JS tests of the mods and of the pi extensions run in node --test. Until
# tests/run starts node beside bashunit, this test runs them in a bashunit run.
function test_the_node_tests_of_the_mods_and_the_pi_extensions_pass() {
  local mods pi output code files=()
  mods=$(node_tests "$ROOT/tests/herdr-app/mods")
  pi=$(node_tests "$ROOT/tests/pi/extensions")
  assert_not_empty "$mods"
  assert_not_empty "$pi"
  [[ -n $mods && -n $pi ]] || return
  while IFS= read -r file; do files+=("$file"); done <<< "$mods"$'\n'"$pi"
  output=$(perl -e 'alarm 30; exec @ARGV' mise x node@latest -- node --test "${files[@]}" 2>&1 < /dev/null)
  code=$?
  assert_same "" "$(grep '^✖' <<< "$output")"
  assert_same "0" "$code"
  assert_matches 'ℹ pass [1-9]' "$output"
}

node_tests() {
  find "$1" -name '*.test.mjs'
}
