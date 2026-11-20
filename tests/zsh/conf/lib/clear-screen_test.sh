#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
CLEAR="$ROOT/zsh/conf/lib/clear-screen"
HOMEBREW_ZSH=/opt/homebrew/bin/zsh

function set_up() {
  SERVER=""
  [[ -f $CLEAR ]] || bashunit::fail "missing the file under test: $CLEAR"
  [[ -x $HOMEBREW_ZSH ]] || bashunit::skip "needs Homebrew zsh"
  command -v tmux > /dev/null || bashunit::skip "needs tmux"
  SERVER="bashunit-$$-$RANDOM"
}

# Types exit, so zsh ends and the tmux server ends with its last session. The
# server leaves its socket file, so tear_down waits at most 5 seconds for the
# server to end, then removes the file.
function tear_down() {
  [[ -n $SERVER ]] || return 0
  tmux -L "$SERVER" send-keys exit Enter 2> /dev/null || true
  for _ in {1..50}; do
    tmux -L "$SERVER" has-session 2> /dev/null || break
    sleep 0.1
  done
  rm -f "${TMUX_TMPDIR:-/tmp}/tmux-$(id -u)/$SERVER"
}

function test_a_clear_keeps_the_lines_of_the_screen_in_the_history() {
  shell_of_24_rows
  type_and_wait "source $CLEAR; seq 1 30" '^30$'

  tmux -L "$SERVER" send-keys C-l
  wait_for_screen_rows 1

  assert_same "1" "$(tmux -L "$SERVER" capture-pane -p -S - | grep -cx 30)"
}

# Starts zsh in a tmux pane of 80 by 24. With scroll-on-clear off, tmux drops
# the screen lines on a clear, as herdr-core does.
shell_of_24_rows() {
  tmux -L "$SERVER" -f /dev/null new-session -d -x 80 -y 24 "$HOMEBREW_ZSH -f" \; \
    set -g scroll-on-clear off < /dev/null
}

# Types $1 and enter, and waits at most 5 seconds until the screen has a line
# that matches $2.
type_and_wait() {
  tmux -L "$SERVER" send-keys "$1" Enter
  for _ in {1..50}; do
    tmux -L "$SERVER" capture-pane -p | grep -q "$2" && return
    sleep 0.1
  done
}

# Waits at most 5 seconds until the screen has $1 rows with text.
wait_for_screen_rows() {
  for _ in {1..50}; do
    [[ $(tmux -L "$SERVER" capture-pane -p | grep -c .) == "$1" ]] && return
    sleep 0.1
  done
}
