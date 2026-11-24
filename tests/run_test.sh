#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PASSING_TEST='function test_passes() { assert_same 1 1; }'
PASSING_CASE='import { test } from "node:test";
import assert from "node:assert/strict";
test("adds", () => assert.equal(1 + 1, 2));'
FAILING_TEST='function test_fails_on_purpose() { assert_same "a" "b"; }'
FAILING_CASE='import { test } from "node:test";
import assert from "node:assert/strict";
test("fails on purpose", () => assert.equal("a", "b"));'
STUCK_TEST='function test_takes_5_seconds() { sleep 5; assert_same 1 1; }'
TERMINAL_TEST='function test_notes_its_terminal() { ps -o tty= -p $$ | tr -d "[:space:]" > terminal; assert_same 1 1; }
function test_notes_the_input_of_its_terminal() {
  if read -r -t 0 < /dev/tty; then echo waiting > input; else echo none > input; fi
  assert_same 1 1
}'
STUCK_CASE='import { test } from "node:test";
test("waits a minute", () => new Promise((resolve) => setTimeout(resolve, 60000)));'

# Each scenario runs tests/run on a small suite of its own. All the runs start
# before the first test.
function set_up_before_script() {
  SUITES=$(bashunit::temp_dir "suites")
  suite passing a_test.sh "$PASSING_TEST" c_test.sh "$PASSING_TEST" b.test.mjs "$PASSING_CASE"
  suite bash_fails a_test.sh "$FAILING_TEST" b.test.mjs "$PASSING_CASE"
  suite node_fails a_test.sh "$PASSING_TEST" b.test.mjs "$FAILING_CASE"
  suite stuck a_test.sh "$STUCK_TEST" b.test.mjs "$STUCK_CASE"
  suite terminal a_test.sh "$TERMINAL_TEST" b.test.mjs "$PASSING_CASE"
  suite no_node a_test.sh "$PASSING_TEST"
  start_run passing
  start_run terminal
  start_run no_node
  suite slow a_test.sh "$PASSING_TEST" b.test.mjs "$PASSING_CASE"
  start_run slow TESTS_BUDGET_MS=1
  start_run bash_fails
  start_run node_fails
  start_run stuck TESTS_TEST_TIMEOUT=1
  wait
}

function test_a_passing_suite_passes() {
  assert_same "0" "$(code_of passing)"
}

function test_counts_the_tests_of_each_runner() {
  assert_contains "bashunit: 2 passed, 0 failed" "$(output_of passing)"
  assert_contains "node: 1 passed, 0 failed" "$(output_of passing)"
}

function test_gives_the_time_of_each_runner_and_of_the_whole_run() {
  assert_matches "bashunit: 2 passed, 0 failed, [0-9]+\.[0-9]{2} s" "$(output_of passing)"
  assert_matches "node: 1 passed, 0 failed, [0-9]+\.[0-9]{2} s" "$(output_of passing)"
  assert_matches "total: [0-9]+\.[0-9]{2} s" "$(output_of passing)"
}

function test_runs_each_bashunit_test_in_a_terminal_of_its_own() {
  local terminal
  terminal=$(cat "$SUITES/terminal/terminal")

  assert_matches "^ttys[0-9]+$" "$terminal"
  assert_not_same "$(ps -o tty= -p $$ | tr -d "[:space:]")" "$terminal"
}

function test_the_terminal_of_the_tests_gives_them_no_input() {
  assert_same "none" "$(cat "$SUITES/terminal/input")"
}

function test_fails_when_the_suite_has_no_node_test_file() {
  assert_same "1" "$(code_of no_node)"
  assert_contains "no node test file in tests" "$(output_of no_node)"
}

function test_a_run_over_its_budget_fails_and_says_so() {
  assert_same "1" "$(code_of slow)"
  assert_matches "over the budget: [0-9]+\.[0-9]{2} s is more than 0\.00 s" "$(output_of slow)"
}

function test_a_failing_bashunit_test_fails_the_run() {
  assert_same "1" "$(code_of bash_fails)"
}

function test_names_a_failing_bashunit_test_and_its_failure() {
  assert_contains "✗ tests/a_test.sh: Fails on purpose" "$(output_of bash_fails)"
  assert_contains "but got  'b'" "$(output_of bash_fails)"
}

function test_a_failing_node_case_fails_the_run() {
  assert_same "1" "$(code_of node_fails)"
}

function test_names_a_failing_node_case_and_its_failure() {
  assert_contains "✖ fails on purpose" "$(output_of node_fails)"
  assert_contains "'a' !== 'b'" "$(output_of node_fails)"
}

function test_a_bashunit_test_over_the_limit_fails_with_its_name() {
  assert_contains "✗ tests/a_test.sh: Takes 5 seconds" "$(output_of stuck)"
  assert_contains "Test timed out after 1s" "$(output_of stuck)"
}

function test_a_node_case_over_the_limit_fails_with_its_name() {
  assert_contains "✖ waits a minute" "$(output_of stuck)"
  assert_contains "test timed out after 1000ms" "$(output_of stuck)"
}

function test_a_node_case_over_the_limit_does_not_hold_the_run_until_its_timer_ends() {
  local seconds
  seconds=$(sed -n 's/^node: .*, \([0-9]*\)\.[0-9]* s$/\1/p' "$SUITES/stuck/output")

  assert_less_than 30 "$seconds"
}

function test_counts_a_node_case_over_the_limit_as_failed() {
  assert_contains "node: 0 passed, 1 failed" "$(output_of stuck)"
}

# Writes the suite $1. Each pair of arguments after it is a file name and its
# text.
suite() {
  local dir="$SUITES/$1/tests"
  shift
  mkdir -p "$dir"
  while (($# > 1)); do
    printf '%s\n' "$2" > "$dir/$1"
    shift 2
  done
}

# Runs tests/run on the suite $1 in the background, with the settings after
# it, such as TESTS_BUDGET_MS=1. The run gets no variable of this bashunit run
# and no setting of the tests/run around it, as a run from a shell does.
start_run() {
  local dir="$SUITES/$1" name setting code=0
  shift
  (
    cd "$dir" || exit
    for name in $(compgen -e); do
      [[ $name == *BASHUNIT* || $name == TESTS_* ]] && { unset "$name" 2> /dev/null || true; }
    done
    for setting in "$@"; do export "${setting?}"; done
    "$ROOT/tests/run" tests > output 2>&1 < /dev/null || code=$?
    echo "$code" > code
  ) &
}

output_of() {
  cat "$SUITES/$1/output"
}

code_of() {
  cat "$SUITES/$1/code"
}
