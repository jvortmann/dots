#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
PLUGIN="$ROOT/zsh/conf/plugins/herdr-nav.zsh"
CLEAR="$ROOT/zsh/conf/lib/clear-screen"
HOMEBREW_ZSH=/opt/homebrew/bin/zsh
# shellcheck source=../../../herdr-app/fake_herdr_app.sh
source "$ROOT/tests/herdr-app/fake_herdr_app.sh"

function set_up() {
  SERVER=""
  [[ -f $PLUGIN ]] || bashunit::fail "missing the file under test: $PLUGIN"
  [[ -x $HOMEBREW_ZSH ]] || bashunit::skip "needs Homebrew zsh"
  command -v tmux > /dev/null || bashunit::skip "needs tmux"
  HOME_DIR=$(bashunit::temp_dir "home")
  LOG="$HOME_DIR/herdr-app.log"
  mkdir -p "$HOME_DIR/.local/bin"
  fake_herdr_app ""
}

# The tmux server leaves its socket file, so tear_down removes it.
function tear_down() {
  [[ -n $SERVER ]] || return 0
  tmux -L "$SERVER" kill-server 2> /dev/null || true
  rm -f "${TMUX_TMPDIR:-/tmp}/tmux-$(id -u)/$SERVER"
}

function test_in_a_herdr_terminal_ctrl_l_moves_the_herdr_pane_right() {
  shell_in_terminal t7

  tmux -L "$SERVER" send-keys C-l

  assert_same 'do pane.go {"direction":"right"}' "$(logged pane.go)"
}

# herdr-app prints {"ok": true}, and a job notice would show on the screen too.
function test_a_pane_move_leaves_the_screen_alone() {
  shell_in_terminal t7

  tmux -L "$SERVER" send-keys C-l
  logged pane.go > /dev/null

  assert_same "%" "$(tmux -L "$SERVER" capture-pane -p | grep .)"
}

function test_the_shell_does_not_wait_for_the_pane_move() {
  fake_herdr_app "sleep 2"
  shell_in_terminal t7
  SECONDS=0

  tmux -L "$SERVER" send-keys C-l
  tmux -L "$SERVER" send-keys "print -r -- ready" Enter
  wait_for_screen '^ready$'

  assert_less_than 2 "$SECONDS"
}

function test_outside_herdr_ctrl_h_j_k_l_keep_their_widgets() {
  shell_in_terminal ""

  tmux -L "$SERVER" send-keys "for key in '^H' '^J' '^K' '^L'; bindkey \$key" Enter
  wait_for_screen '^"^L"'

  assert_same $'"^H" backward-delete-char\n"^J" accept-line\n"^K" kill-line\n"^L" _clear_screen_into_history' \
    "$(tmux -L "$SERVER" capture-pane -p | grep '^"^')"
}

# keys.json sends ctrl-l in the CSI u form for ctrl-a ctrl-l, so the chord
# still clears in Herdr.
function test_in_a_herdr_terminal_ctrl_l_in_the_csi_u_form_clears_the_screen_into_the_history() {
  shell_in_terminal t7
  tmux -L "$SERVER" send-keys "seq 1 30" Enter
  wait_for_screen '^30$'

  tmux -L "$SERVER" send-keys -l $'\e[108;5u'
  wait_for_screen_rows 1

  assert_same "1" "$(tmux -L "$SERVER" capture-pane -p -S - -E -1 | grep -cx 30)"
}

# keys.json sends ctrl-alt-k in the CSI u form for ctrl-a ctrl-k, so the chord
# still kills in Herdr.
function test_in_a_herdr_terminal_ctrl_alt_k_kills_to_the_end_of_the_line() {
  shell_in_terminal t7

  kill_with_ctrl_alt_k

  assert_same "% print -r -- keep" "$(tmux -L "$SERVER" capture-pane -p | grep '^% print')"
}

# keys.json sends ctrl-alt-j in the CSI u form for ctrl-a ctrl-j, so the chord
# runs the line as ctrl-j did.
function test_in_a_herdr_terminal_ctrl_alt_j_runs_the_line() {
  shell_in_terminal t7
  tmux -L "$SERVER" send-keys "print -r -- ran"
  wait_for_screen 'ran$'

  tmux -L "$SERVER" send-keys -l $'\e[106;7u'
  wait_for_screen '^ran$'

  assert_same "ran" "$(tmux -L "$SERVER" capture-pane -p | grep -x ran)"
}

# A second source of the zshrc must not give ctrl-alt-k the pane move that
# ctrl-k now has.
function test_after_a_second_load_ctrl_alt_k_still_kills_to_the_end_of_the_line() {
  shell_in_terminal t7
  tmux -L "$SERVER" send-keys "source $(printf %q "$PLUGIN"); clear" Enter
  wait_for_screen_rows 1

  kill_with_ctrl_alt_k

  assert_same "% print -r -- keep" "$(tmux -L "$SERVER" capture-pane -p | grep '^% print')"
}

# Starts zsh in a tmux pane of 80 by 24, in the Herdr terminal with the id $1,
# or outside Herdr when $1 is empty. The zshrc picks the emacs keymap, as
# zsh/conf/defaults does, and loads lib/clear-screen before the plugin, as
# zsh/init.zsh does. Waits at most 5 seconds for the prompt.
# With scroll-on-clear off, tmux drops the screen lines on a clear, as
# herdr-core does.
shell_in_terminal() {
  SERVER="bashunit-$$-$RANDOM"
  printf 'bindkey -e\nsource %q\nsource %q\nPS1="%%%% "\n' "$CLEAR" "$PLUGIN" > "$HOME_DIR/.zshrc"
  tmux -L "$SERVER" -f /dev/null new-session -d -x 80 -y 24 -e HOME="$HOME_DIR" -e ZDOTDIR="$HOME_DIR" \
    -e HC_TERMINAL_ID="$1" -e PATH=/usr/bin:/bin "$HOMEBREW_ZSH -i" \; set -g scroll-on-clear off < /dev/null
  wait_for_screen '^%'
}

# Types a command line, moves the cursor before its last 4 characters, and
# sends ctrl-alt-k in the CSI u form. Waits at most 5 seconds for each step.
kill_with_ctrl_alt_k() {
  tmux -L "$SERVER" send-keys "print -r -- keep-cut" Left Left Left Left
  wait_for_screen 'keep-cut$'
  tmux -L "$SERVER" send-keys -l $'\e[107;7u'
  wait_for_screen 'keep$'
}

# Waits at most 5 seconds until the screen has a line that matches $1.
wait_for_screen() {
  for _ in {1..50}; do
    tmux -L "$SERVER" capture-pane -p | grep -q -- "$1" && return
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

# Waits at most 5 seconds until a line of the log matches $1, then prints the
# first such line.
logged() {
  for _ in {1..50}; do
    grep -m 1 -- "$1" "$LOG" 2> /dev/null && return
    sleep 0.1
  done
}
