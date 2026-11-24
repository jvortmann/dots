#!/bin/bash

FAKE_PROGRAM="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/fake"

# Shell code for a fake that waits until release_fakes runs on its folder.
# It also stops when the folder goes, and after 1000 polls. A test of a call
# that must not block uses it.
# shellcheck disable=SC2016
FAKE_GATE='d=$(dirname "$0"); i=0; while [ -d "$d" ] && [ ! -e "$d/.release" ] && [ $i -lt 1000 ]; do sleep 0.01; i=$((i + 1)); done'

# Puts a program called $2 in the folder $1. It runs the shell code in $3 with
# the arguments of the call. The program is a link to the one fake program.
fake_program() {
  mkdir -p "$1"
  printf '%s\n' "$3" > "$1/$2.sh"
  ln -sf "$FAKE_PROGRAM" "$1/$2"
}

# Lets each gated fake in the folder $1 go on.
release_fakes() {
  [[ -d $1 ]] && : > "$1/.release"
  return 0
}
