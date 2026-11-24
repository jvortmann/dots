#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
CLEAR="$ROOT/zsh/conf/lib/clear-screen"
HOMEBREW_ZSH=/opt/homebrew/bin/zsh
# shellcheck source=../../../tmux_shell.sh
source "$ROOT/tests/tmux_shell.sh"

function set_up() {
  SERVER=""
  [[ -f $CLEAR ]] || bashunit::fail "missing the file under test: $CLEAR"
  [[ -x $HOMEBREW_ZSH ]] || bashunit::skip "needs Homebrew zsh"
  command -v tmux > /dev/null || bashunit::skip "needs tmux"
  SERVER="bashunit-$$-$RANDOM"
}

# The tmux server leaves its socket file, so tear_down removes it.
function tear_down() {
  [[ -n $SERVER ]] || return 0
  tmux -L "$SERVER" kill-server 2> /dev/null || true
  rm -f "${TMUX_TMPDIR:-/tmp}/tmux-$(id -u)/$SERVER"
}

function test_a_clear_keeps_the_lines_of_the_screen_in_the_history() {
  shell_of_24_rows
  run_in_shell "source $CLEAR; seq 1 30"

  tmux -L "$SERVER" send-keys C-l
  run_in_shell ":"

  assert_same "1" "$(tmux -L "$SERVER" capture-pane -p -S - | grep -cx 30)"
}

# Starts zsh in a tmux pane of 80 by 24. With scroll-on-clear off, tmux drops
# the screen lines on a clear, as herdr-core does.
shell_of_24_rows() {
  tmux -L "$SERVER" -f /dev/null new-session -d -x 80 -y 24 "$HOMEBREW_ZSH -f" \; \
    set -g scroll-on-clear off < /dev/null
}
