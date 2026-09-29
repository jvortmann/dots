#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
COMPLETION="$ROOT/zsh/conf/completion.zsh"
HOMEBREW_ZSH=/opt/homebrew/bin/zsh
APPLE_ZSH=/bin/zsh

# Load completion.zsh in a zsh with an empty home, so the dump it writes stays
# in the test. Print each completion function that the shell registered but
# cannot load.
unloadable_completions() {
  local zsh=$1 home=$2
  HOME="$home" ZSH_HOME="$home" "$zsh" -f -c '
    source "$1" 2>/dev/null
    for fn in ${(u)_comps}; do
      autoload +X "$fn" 2>/dev/null || print -r -- "$fn"
    done
  ' _ "$COMPLETION"
}

function set_up() {
  [[ -f $COMPLETION ]] || bashunit::fail "missing the file under test: $COMPLETION"
  [[ -x $HOMEBREW_ZSH && -x $APPLE_ZSH ]] || bashunit::skip "needs Homebrew zsh and Apple zsh"
}

function test_apple_zsh_can_load_every_completion_after_homebrew_zsh_ran_first() {
  local home
  home=$(bashunit::temp_dir "completion")
  unloadable_completions "$HOMEBREW_ZSH" "$home" > /dev/null

  assert_empty "$(unloadable_completions "$APPLE_ZSH" "$home")"
}
