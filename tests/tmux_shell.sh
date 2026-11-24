#!/bin/bash

TMUX_BIN=$(command -v tmux)
TMUX_SIGNALS=0

# Types the command line $1 and enter into the shell of the tmux server
# $SERVER. It returns when the shell ran that line. The line ends with a
# signal of `tmux wait-for`, and tmux remembers a signal that comes first. So
# the tmux server has the output of the line before this function returns.
run_in_shell() {
  TMUX_SIGNALS=$((TMUX_SIGNALS + 1))
  "$TMUX_BIN" -L "$SERVER" send-keys "$1; $TMUX_BIN wait-for -S ran-$TMUX_SIGNALS" Enter
  signaled "ran-$TMUX_SIGNALS"
}

# Returns when a program in a pane of the tmux server $SERVER ran
# `tmux wait-for -S $1`. A signal that never comes fails the test after 5
# seconds, so a broken test cannot stop the suite.
signaled() {
  perl -e 'alarm 5; exec @ARGV' "$TMUX_BIN" -L "$SERVER" wait-for "$1"
}
