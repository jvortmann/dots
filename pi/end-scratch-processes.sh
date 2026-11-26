#!/usr/bin/env bash
# Ends the leftover processes of agents and of tests/run.
# Usage: end-scratch-processes.sh <pid>...
#
# It ends only a process whose command line holds /tmp/scratch/, a tests-run.
# work folder in a temp folder, or the tmux socket tests-run-*. It sends TERM,
# and then KILL when the process still runs after END_SCRATCH_WAIT_MS (2000 by
# default). It refuses every other process and exits with 1. A process that no
# longer runs is not an error.

main() {
  local pid status=0
  for pid in "$@"; do
    end_process "$pid" || status=1
  done
  return "$status"
}

end_process() {
  local command
  if [[ ! $1 =~ ^[0-9]+$ ]]; then
    echo "refuses $1: it is not a process id" >&2
    return 1
  fi
  command=$(ps -o command= -p "$1" 2> /dev/null)
  if [[ -z $command ]] || ! is_running "$1"; then
    echo "no process $1: nothing to end"
    return 0
  fi
  if ! is_leftover "$command"; then
    echo "refuses $1: its command line holds no scratch or test folder" >&2
    return 1
  fi
  kill -TERM "$1"
  wait_for_end "$1" && return 0
  kill -KILL "$1"
  if ! wait_for_end "$1"; then
    echo "cannot end $1: it still runs after KILL" >&2
    return 1
  fi
  echo "sent KILL to $1: it still ran after TERM"
}

# Succeeds when the process $1 ends within END_SCRATCH_WAIT_MS.
wait_for_end() {
  local deadline=$(($(now_ms) + ${END_SCRATCH_WAIT_MS:-2000}))
  while is_running "$1"; do
    (($(now_ms) < deadline)) || return 1
    sleep 0.05
  done
}

is_leftover() {
  local start='(^|[[:space:]=])(/private)?'
  local temp="$start(/tmp|/var/folders/[^/[:space:]]+/[^/[:space:]]+/T)/+"
  [[ $1 =~ ${start}/tmp/scratch/ || $1 =~ ${temp}tests-run\. || $1 == *" -L tests-run-"* ]]
}

is_running() {
  local state
  state=$(ps -o stat= -p "$1" 2> /dev/null)
  state=${state// /}
  [[ -n $state && $state != Z* ]]
}

now_ms() {
  local micro=${EPOCHREALTIME/./}
  echo "$((micro / 1000))"
}

main "$@"
