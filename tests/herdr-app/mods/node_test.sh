#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

# The JS tests of the mods run in node --test. Until tests/run starts node
# beside bashunit, this test runs them in a bashunit run.
function test_the_node_tests_of_the_mods_pass() {
  local output code
  output=$(mise x node@latest -- node --test "$ROOT/tests/herdr-app/mods/**/*.test.mjs" 2>&1 < /dev/null)
  code=$?
  assert_same "" "$(grep '^✖' <<< "$output")"
  assert_same "0" "$code"
  assert_matches 'ℹ pass [1-9]' "$output"
}
