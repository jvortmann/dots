#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
VIEW="$ROOT/herdr-app/mods/copy-mode/view.sh"
# shellcheck source=../../../fakes/fakes.sh
source "$ROOT/tests/fakes/fakes.sh"

function set_up() {
  [[ -f $VIEW ]] || bashunit::fail "missing the file under test: $VIEW"
  SCRATCH=$(bashunit::temp_dir "copy-mode")
  fake hc 'exit 3'
  fake nvim 'printf "%s\n" "$*" > "$SCRATCH/nvim.args"; command -v hc > "$SCRATCH/hc.path"'
}

function test_opens_nvim_with_the_copy_mode_config_and_no_user_config() {
  view

  assert_same "--clean -u $(dirname "$VIEW")/nvim.lua --noplugin -n" "$(cat "$SCRATCH/nvim.args")"
}

function test_finds_hc_and_nvim_on_the_bare_path_of_the_core() {
  mkdir -p "$SCRATCH/home/.local"
  mv "$SCRATCH/bin" "$SCRATCH/home/.local/bin"

  HOME="$SCRATCH/home" SCRATCH="$SCRATCH" PATH=/usr/bin:/bin:/usr/sbin:/sbin /bin/sh "$VIEW" < /dev/null

  assert_same "$SCRATCH/home/.local/bin/hc" "$(cat "$SCRATCH/hc.path")"
}

view() {
  SCRATCH="$SCRATCH" PATH="$SCRATCH/bin:$PATH" sh "$VIEW" "$@" < /dev/null
}

# Puts a program called $1 first on the PATH of view, which runs the shell
# code in $2.
fake() {
  fake_program "$SCRATCH/bin" "$1" "$2"
}
