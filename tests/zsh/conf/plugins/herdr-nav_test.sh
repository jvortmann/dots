#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
PLUGIN="$ROOT/zsh/conf/plugins/herdr-nav.zsh"
CLEAR="$ROOT/zsh/conf/lib/clear-screen"
HOMEBREW_ZSH=/opt/homebrew/bin/zsh
# shellcheck source=../../../herdr-app/fake_herdr_app.sh
source "$ROOT/tests/herdr-app/fake_herdr_app.sh"
# shellcheck source=../../../tmux_shell.sh
source "$ROOT/tests/tmux_shell.sh"

function set_up() {
  SERVER=""
  [[ -f $PLUGIN ]] || bashunit::fail "missing the file under test: $PLUGIN"
  [[ -x $HOMEBREW_ZSH ]] || bashunit::skip "needs Homebrew zsh"
  command -v tmux > /dev/null || bashunit::skip "needs tmux"
  HOME_DIR=$(bashunit::temp_dir "home")
  LOG="$HOME_DIR/herdr-app.log"
  mkdir -p "$HOME_DIR/.local/bin"
  fake_herdr_app ""
  open_channel "$HOME_DIR/.local/bin/herdr-app"
}

# The tmux server leaves its socket file, so tear_down removes it.
function tear_down() {
  [[ -n $SERVER ]] || return 0
  tmux -L "$SERVER" kill-server 2> /dev/null || true
  rm -f "${TMUX_TMPDIR:-/tmp}/tmux-$(id -u)/$SERVER"
}

# @data_provider keys_and_directions
function test_in_a_herdr_terminal_ctrl_h_j_k_l_move_the_herdr_pane() {
  shell_in_terminal t7

  tmux -L "$SERVER" send-keys "$1"
  read_reports 1

  assert_same "do pane.go {\"direction\":\"$2\"}" "$(logged pane.go)"
}

function keys_and_directions() {
  bashunit::data_set C-h left
  bashunit::data_set C-j down
  bashunit::data_set C-k up
  bashunit::data_set C-l right
}

# herdr-app prints {"ok": true}, and a job notice would show on the screen too.
function test_a_pane_move_leaves_the_screen_alone() {
  shell_in_terminal t7

  tmux -L "$SERVER" send-keys C-l
  read_reports 1
  zle_ran_the_keys

  assert_same "%" "$(tmux -L "$SERVER" capture-pane -p | grep .)"
}

function test_the_shell_does_not_wait_for_the_pane_move() {
  fake_herdr_app "$FAKE_GATE"
  open_gate "$HOME_DIR/.local/bin/herdr-app"
  shell_in_terminal t7
  SECONDS=0

  tmux -L "$SERVER" send-keys C-l
  run_in_shell "print -r -- ready"

  assert_less_than 2 "$SECONDS"
  read_reports 1
}

function test_outside_herdr_ctrl_h_j_k_l_keep_their_widgets() {
  shell_in_terminal ""

  run_in_shell "for key in '^H' '^J' '^K' '^L'; bindkey \$key"

  assert_same $'"^H" backward-delete-char\n"^J" accept-line\n"^K" kill-line\n"^L" _clear_screen_into_history' \
    "$(tmux -L "$SERVER" capture-pane -p | grep '^"^')"
}

# keys.json sends ctrl-l in the CSI u form for ctrl-a ctrl-l, so the chord
# still clears in Herdr.
function test_in_a_herdr_terminal_ctrl_l_in_the_csi_u_form_clears_the_screen_into_the_history() {
  shell_in_terminal t7
  run_in_shell "seq 1 30"

  tmux -L "$SERVER" send-keys -l $'\e[108;5u'
  run_in_shell ":"

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

  tmux -L "$SERVER" send-keys -l $'\e[106;7u'
  run_in_shell ":"

  assert_same "ran" "$(tmux -L "$SERVER" capture-pane -p | grep -x ran)"
}

# A second source of the zshrc must not give ctrl-alt-k the pane move that
# ctrl-k now has.
function test_after_a_second_load_ctrl_alt_k_still_kills_to_the_end_of_the_line() {
  shell_in_terminal t7
  run_in_shell "source $(printf %q "$PLUGIN"); clear"

  kill_with_ctrl_alt_k

  assert_same "% print -r -- keep" "$(tmux -L "$SERVER" capture-pane -p | grep '^% print')"
}

# Starts zsh in a tmux pane of 80 by 24. It runs in the Herdr terminal with
# the id $1, or outside Herdr when $1 is empty. The zshrc picks the emacs keymap, as
# zsh/conf/defaults does, and loads lib/clear-screen before the plugin, as
# zsh/init.zsh does.
#
# It returns when the line editor reads the first line.
# A key sent before that reaches a terminal that is not in the mode of the
# line editor yet. So the zshrc signals from the first zle-line-init, and that
# hook then removes itself. F12 runs a widget that only signals, for
# zle_ran_the_keys.
#
# With scroll-on-clear off, tmux drops the screen lines on a clear, as
# herdr-core does.
shell_in_terminal() {
  SERVER="bashunit-$$-$RANDOM"
  ZLE_SIGNALS=0
  printf 'bindkey -e\nsource %q\nsource %q\nPS1="%%%% "\n' "$CLEAR" "$PLUGIN" > "$HOME_DIR/.zshrc"
  printf 'autoload -Uz add-zle-hook-widget\n_test_ready() { add-zle-hook-widget -d line-init _test_ready; %q wait-for -S ready; }\nadd-zle-hook-widget line-init _test_ready\n' \
    "$TMUX_BIN" >> "$HOME_DIR/.zshrc"
  printf '_test_n=0\n_test_signal() { (( _test_n++ )); %q wait-for -S zle-$_test_n; }\nzle -N _test_signal\nbindkey %s _test_signal\n' \
    "$TMUX_BIN" "'\e[24~'" >> "$HOME_DIR/.zshrc"
  tmux -L "$SERVER" -f /dev/null new-session -d -x 80 -y 24 -e HOME="$HOME_DIR" -e ZDOTDIR="$HOME_DIR" \
    -e HC_TERMINAL_ID="$1" -e PATH=/usr/bin:/bin "$HOMEBREW_ZSH -i" \; set -g scroll-on-clear off < /dev/null
  signaled ready
}

# Types a command line and moves the cursor before its last 4 characters.
# Then it sends ctrl-alt-k in the CSI u form and runs the line that is left.
kill_with_ctrl_alt_k() {
  tmux -L "$SERVER" send-keys "print -r -- keep-cut" Left Left Left Left
  tmux -L "$SERVER" send-keys -l $'\e[107;7u'
  tmux -L "$SERVER" send-keys Enter
  run_in_shell ":"
}

# Returns when zsh ran each key that the test sent before. It sends F12, and
# zsh runs a key only after the keys before it.
zle_ran_the_keys() {
  ZLE_SIGNALS=$((ZLE_SIGNALS + 1))
  tmux -L "$SERVER" send-keys F12
  signaled "zle-$ZLE_SIGNALS"
}

# Prints the first line of the log of the fake herdr-app that matches $1.
logged() {
  grep -m 1 -- "$1" "$LOG" 2> /dev/null
}
