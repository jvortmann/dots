#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT/zsh/setup.sh"
# shellcheck source=../fakes/fakes.sh
source "$ROOT/tests/fakes/fakes.sh"

function set_up() {
  [[ -f $SCRIPT ]] || bashunit::fail "missing the file under test: $SCRIPT"
  HOME_DIR=$(bashunit::temp_dir "home")
  STUBS=$(bashunit::temp_dir "stubs")
  fake_program "$STUBS" sudo ""
  fake_program "$STUBS" chsh ""
}

function test_links_the_zshenv_to_dots() {
  run_setup

  assert_same "$HOME_DIR/.dots/zsh/zshenv" "$(readlink "$HOME_DIR/.zshenv")"
}

# The stubs stand in for sudo and chsh, so the run changes no system file.
run_setup() {
  HOME="$HOME_DIR" PATH="$STUBS:$PATH" "$SCRIPT" > /dev/null 2>&1
}
