#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
IGNORE="$ROOT/git/ignore"

function set_up() {
  [[ -f $IGNORE ]] || bashunit::fail "missing the file under test: $IGNORE"
  REPO=$(bashunit::temp_dir "repo")
  git init -q "$REPO"
}

function test_ignores_a_core_socket_in_the_herdr_core_folder() {
  assert_same "herdr-core/default.sock" "$(ignored herdr-core/default.sock)"
}

function test_keeps_the_core_config_in_the_herdr_core_folder() {
  assert_same "" "$(ignored herdr-core/config.toml)"
}

ignored() {
  git -C "$REPO" -c core.excludesFile="$IGNORE" check-ignore "$1"
}
