#!/bin/bash

# Runs the command in $2 and after it every 20 ms until it succeeds, for $1
# seconds at most. Fails when the command still fails at the end.
wait_until() {
  local tries=$(($1 * 50)) i
  shift
  for ((i = 0; i < tries; i++)); do
    "$@" && return 0
    sleep 0.02
  done
  "$@"
}
