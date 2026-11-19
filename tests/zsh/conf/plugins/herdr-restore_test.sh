#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
PLUGIN="$ROOT/zsh/conf/plugins/herdr-restore.zsh"
HOMEBREW_ZSH=/opt/homebrew/bin/zsh

function set_up() {
  INPUT=""
  [[ -f $PLUGIN ]] || bashunit::fail "missing the file under test: $PLUGIN"
  [[ -x $HOMEBREW_ZSH ]] || bashunit::skip "needs Homebrew zsh"
  HOME_DIR=$(bashunit::temp_dir "home")
  BIN=$(bashunit::temp_dir "bin")
  LOG="$HOME_DIR/hc.log"
  mkdir -p "$HOME_DIR/.local/bin"
  fake_hc ""
  for program in nvim vim vi v pi pip; do
    printf '#!/bin/sh\nexit 0\n' > "$BIN/$program"
    chmod +x "$BIN/$program"
  done
}

function tear_down() {
  [[ -n $INPUT ]] || return 0
  [[ -s $HOME_DIR/pi.pid ]] && kill "$(cat "$HOME_DIR/pi.pid")" 2> /dev/null || true
  exec 3>&-
}

function test_a_herdr_terminal_records_the_nvim_command_line_while_it_runs() {
  in_herdr_shell "nvim notes.md"

  assert_same "label t7 restore.cmd=nvim notes.md" "$(hc_calls 1 | head -1)"
}

function test_the_record_goes_when_the_command_ends() {
  in_herdr_shell "nvim notes.md"

  assert_same $'label t7 restore.cmd=nvim notes.md\nlabel t7 restore.cmd=' "$(hc_calls 2)"
}

# @data_provider the_other_names_of_nvim_and_pi
function test_a_herdr_terminal_records_the_other_names_of_nvim_and_pi() {
  in_herdr_shell "$1 notes.md"

  assert_same "label t7 restore.cmd=$1 notes.md" "$(hc_calls 1 | head -1)"
}

function the_other_names_of_nvim_and_pi() {
  bashunit::data_set vim
  bashunit::data_set vi
  bashunit::data_set v
  bashunit::data_set pi
}

function test_a_herdr_terminal_records_a_command_with_no_arguments() {
  in_herdr_shell "pi"

  assert_same "label t7 restore.cmd=pi" "$(hc_calls 1 | head -1)"
}

# The nvim line comes last. Had pip called hc, the first logged call would
# be the one of pip.
function test_another_command_leaves_the_labels_alone() {
  in_herdr_shell "pip list" "nvim notes.md"

  assert_same "label t7 restore.cmd=nvim notes.md" "$(hc_calls 1 | head -1)"
}

function test_a_shell_outside_herdr_calls_no_hc() {
  TERMINAL_ID="" in_herdr_shell "nvim notes.md"
  sleep 0.5

  assert_file_not_exists "$LOG"
}

function test_the_shell_does_not_wait_for_hc() {
  fake_hc "sleep 3"
  SECONDS=0

  in_herdr_shell "nvim notes.md"

  assert_less_than 3 "$SECONDS"
}

# hc sets the label slower than it clears it, so a clear that does not wait
# runs first and leaves the record of a command that already ended.
function test_a_command_that_ends_at_once_leaves_no_record() {
  fake_hc 'case "$*" in *=) ;; *) sleep 0.5 ;; esac'

  in_herdr_shell "nvim --version"

  assert_same $'label t7 restore.cmd=nvim --version\nlabel t7 restore.cmd=' "$(hc_calls 2)"
}

# A shutdown sends a signal to the shell and to pi: SIGTERM at a reboot, SIGHUP
# when the terminal closes. For each signal, the record must stay.
# @data_provider shutdown_signals
function test_a_shell_that_a_shutdown_ends_keeps_the_record() {
  shell_that_runs_pi

  kill "-$1" "$SHELL_PID" "$(cat "$HOME_DIR/pi.pid")"
  sleep 1

  assert_same "label t7 restore.cmd=pi" "$(cat "$LOG")"
}

function shutdown_signals() {
  bashunit::data_set TERM
  bashunit::data_set HUP
}

# A SIGTERM that ends no shutdown, such as a kill of the shell, leaves an
# interactive zsh alive, and its next command must clear its record again.
function test_a_shell_that_lives_on_after_sigterm_clears_the_next_record() {
  shell_that_runs_pi
  kill -TERM "$SHELL_PID" "$(cat "$HOME_DIR/pi.pid")"
  sleep 1

  printf '%s\n' "nvim notes.md" >&3

  assert_same $'label t7 restore.cmd=pi\nlabel t7 restore.cmd=nvim notes.md\nlabel t7 restore.cmd=' "$(hc_calls 3)"
}

# hc clears slower than it sets, so a clear that the next write does not wait
# for removes the record of pi while pi runs.
function test_the_clear_of_a_command_does_not_remove_the_record_of_the_next() {
  fake_hc 'case "$*" in *=) sleep 0.5 ;; esac'

  shell_that_runs_pi "nvim --version"

  assert_same $'label t7 restore.cmd=nvim --version\nlabel t7 restore.cmd=\nlabel t7 restore.cmd=pi' "$(hc_calls 3)"
}

# Types each argument, then pi, into an interactive zsh in a Herdr terminal.
# pi ends on SIGTERM or SIGHUP, or after 10 seconds. The shell reads its lines
# from a fifo, so it keeps running until tear_down closes the fifo. Waits for
# pi and for the first record.
shell_that_runs_pi() {
  INPUT="$HOME_DIR/input"
  printf '#!/bin/sh\necho $$ > "$HOME/pi.pid"\ntrap "exit 143" TERM HUP\nfor i in $(seq 100); do sleep 0.1; done\n' > "$BIN/pi"
  mkfifo "$INPUT"
  (
    export HC_TERMINAL_ID=t7
    HOME="$HOME_DIR" PATH="$BIN:/usr/bin:/bin" exec "$HOMEBREW_ZSH" -f -i < "$INPUT" > /dev/null 2>&1
  ) &
  SHELL_PID=$!
  exec 3> "$INPUT"
  printf '%s\n' "source ${PLUGIN@Q}" "$@" pi >&3
  for _ in {1..50}; do
    [[ -s $HOME_DIR/pi.pid ]] && break
    sleep 0.1
  done
  hc_calls 1 > /dev/null
}

# Types each argument as one command line into an interactive zsh that loads
# the plugin, in a Herdr terminal with the id t7. An empty TERMINAL_ID runs the
# shell outside Herdr.
in_herdr_shell() {
  (
    unset HC_TERMINAL_ID
    [[ -n ${TERMINAL_ID-t7} ]] && export HC_TERMINAL_ID=${TERMINAL_ID-t7}
    printf '%s\n' "source ${PLUGIN@Q}" "$@" |
      HOME="$HOME_DIR" PATH="$BIN:/usr/bin:/bin" "$HOMEBREW_ZSH" -f -i > /dev/null 2>&1
  )
}

# The hc of the user is not on PATH, so the plugin runs ~/.local/bin/hc. This
# fake logs its arguments. $1 is a shell line that runs before the log.
fake_hc() {
  printf '#!/bin/sh\n%s\necho "$*" >> %q\n' "$1" "$LOG" > "$HOME_DIR/.local/bin/hc"
  chmod +x "$HOME_DIR/.local/bin/hc"
}

# Waits at most 5 seconds until the fake hc logged $1 calls, then prints the
# log. The plugin runs hc in the background.
hc_calls() {
  for _ in {1..50}; do
    [[ $(wc -l 2> /dev/null < "$LOG") -ge $1 ]] && break
    sleep 0.1
  done
  cat "$LOG" 2> /dev/null
}
