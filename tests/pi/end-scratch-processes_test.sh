#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT/pi/end-scratch-processes.sh"
# shellcheck source=../fakes/fakes.sh
source "$ROOT/tests/fakes/fakes.sh"
# A process of the test reports on the channel of the test, and then blocks
# with no poll. When a broken run never stops it, it ends after 10 seconds.
# shellcheck disable=SC2016
STAY='alarm 10; open(my $c, ">", $ENV{CHANNEL}) or exit; print $c "done\n"; close $c; select(undef, undef, undef, undef)'
# Put before STAY, it makes a process that ignores TERM.
# shellcheck disable=SC2016
IGNORE_TERM='$SIG{TERM} = "IGNORE"; '

function set_up() {
  [[ -x $SCRIPT ]] || bashunit::fail "missing the file under test: $SCRIPT"
  mkdir -p /tmp/scratch
  SCRATCH=$(mktemp -d /tmp/scratch/end-scratch-processes-test.XXXXXX)
  STARTED=()
  open_channel "$SCRATCH/process"
}

function tear_down() {
  kill -KILL "${STARTED[@]}" 2> /dev/null || true
  rm -r "$SCRATCH"
}

function test_ends_a_process_whose_command_line_holds_the_scratch_folder() {
  start_process "$STAY" "$SCRATCH/bashunit-001.in"

  "$SCRIPT" "$PID" > /dev/null 2>&1 < /dev/null

  assert_same "ended" "$(state_of "$PID")"
}

function test_ends_the_processes_in_a_work_folder_of_tests_run_under_each_temp_folder() {
  local folder pids=()
  for folder in "${TMPDIR:-/tmp}" /tmp /private/tmp /var/folders/ab/cd/T; do
    start_process "$STAY" "$folder/tests-run.Ab12Cd/pi_permissions.log"
    pids+=("$PID")
  done

  "$SCRIPT" "${pids[@]}" > /dev/null 2>&1 < /dev/null

  assert_same "ended ended ended ended" "$(states_of "${pids[@]}")"
}

function test_ends_a_tmux_server_on_a_socket_of_tests_run() {
  start_process "$STAY" -L tests-run-4242 -f /dev/null new-session -d

  "$SCRIPT" "$PID" > /dev/null 2>&1 < /dev/null

  assert_same "ended" "$(state_of "$PID")"
}

function test_refuses_a_process_outside_the_scratch_and_test_folders() {
  start_process "$STAY" /tmp/other/notes.txt

  local error
  error=$("$SCRIPT" "$PID" 2>&1 > /dev/null < /dev/null)

  assert_same "1 refuses $PID: its command line holds no scratch or test folder" "$? $error"
  assert_same "running" "$(state_of "$PID")"
}

function test_refuses_a_folder_in_the_home_folder_that_ends_like_a_scratch_or_test_folder() {
  start_process "$STAY" /Users/someone/tmp/scratch/notes.txt
  local scratch=$PID
  start_process "$STAY" /Users/someone/tmp/tests-run.Ab12Cd/notes.txt

  "$SCRIPT" "$scratch" "$PID" > /dev/null 2>&1 < /dev/null

  assert_same "running running" "$(states_of "$scratch" "$PID")"
}

function test_sends_kill_to_a_process_that_still_runs_after_term() {
  start_process "$IGNORE_TERM$STAY" "$SCRATCH/bashunit-001.in"

  local output
  output=$(END_SCRATCH_WAIT_MS=100 "$SCRIPT" "$PID" 2>&1 < /dev/null)

  assert_same "sent KILL to $PID: it still ran after TERM ended" "$output $(state_of "$PID")"
}

function test_succeeds_for_a_process_that_no_longer_runs() {
  local output
  output=$("$SCRIPT" 99999999 2>&1 < /dev/null)

  assert_same "0 no process 99999999: nothing to end" "$? $output"
}

function test_refuses_an_argument_that_is_not_a_process_id() {
  local error
  error=$("$SCRIPT" -1 2>&1 > /dev/null < /dev/null)

  assert_same "1 refuses -1: it is not a process id" "$? $error"
}

# Starts perl with the code $1 and the arguments after it, which show in its
# command line. It runs apart from the test shell, as a leftover does, so no
# zombie stays after it ends. It returns when the process reports. Sets PID.
start_process() {
  local code=$1
  shift
  PID=$(CHANNEL="$SCRATCH/process.channel" perl -e "$code" -- "$@" > /dev/null 2>&1 < /dev/null & echo $!)
  STARTED+=("$PID")
  read_reports 1 || bashunit::fail "the process $PID did not report"
}

# Prints the state of each process, as state_of does, on one line.
states_of() {
  local pid states=()
  for pid in "$@"; do
    states+=("$(state_of "$pid")")
  done
  echo "${states[*]}"
}

# Prints "running" when the process $1 runs, or "ended" when it is gone or a
# zombie.
state_of() {
  local state
  state=$(ps -o stat= -p "$1" 2> /dev/null)
  state=${state// /}
  if [[ -n $state && $state != Z* ]]; then echo running; else echo ended; fi
}
