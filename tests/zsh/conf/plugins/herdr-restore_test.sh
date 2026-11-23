#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
PLUGIN="$ROOT/zsh/conf/plugins/herdr-restore.zsh"
HOMEBREW_ZSH=/opt/homebrew/bin/zsh

function set_up() {
  INPUT=""
  SERVER=""
  [[ -f $PLUGIN ]] || bashunit::fail "missing the file under test: $PLUGIN"
  [[ -x $HOMEBREW_ZSH ]] || bashunit::skip "needs Homebrew zsh"
  command -v tmux > /dev/null || bashunit::skip "needs tmux"
  HOME_DIR=$(bashunit::temp_dir "home")
  BIN=$(bashunit::temp_dir "bin")
  LOG="$HOME_DIR/hc.log"
  mkdir -p "$HOME_DIR/.local/bin"
  fake_hc ""
  for program in nvim vim vi v n pi pip; do
    printf '#!/bin/sh\nexit 0\n' > "$BIN/$program"
    chmod +x "$BIN/$program"
  done
}

# Types exit, so zsh ends and the tmux server ends with its last session. The
# server leaves its socket file, so tear_down removes it.
function tear_down() {
  if [[ -n $SERVER ]]; then
    tmux -L "$SERVER" send-keys exit Enter 2> /dev/null
    rm -f "${TMUX_TMPDIR:-/tmp}/tmux-$(id -u)/$SERVER"
  fi
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
  bashunit::data_set n
  bashunit::data_set pi
}

function test_a_herdr_terminal_records_a_command_with_no_arguments() {
  in_herdr_shell "pi"

  assert_same "label t7 restore.cmd=pi" "$(hc_calls 1 | head -1)"
}

# The pi line comes last. Had pip called hc, the first logged call would be
# the one of pip.
function test_another_command_leaves_the_labels_alone() {
  in_herdr_shell "pip list" "pi"

  assert_same "label t7 restore.cmd=pi" "$(hc_calls 1 > /dev/null; head -1 "$LOG")"
}

# An nvim that saves no session, such as nvim --clean, must not leave the
# label of an earlier nvim. An nvim that saves one labels itself again.
function test_a_herdr_terminal_clears_the_nvim_session_when_nvim_starts() {
  in_herdr_shell "nvim notes.md"

  assert_same "label t7 restore.nvim=" "$(logged restore.nvim=)"
}

# nvim labels itself at start, so a clear that lands later removes that label.
function test_the_nvim_session_clears_before_nvim_starts() {
  fake_hc 'case "$*" in *restore.nvim=) sleep 0.5 ;; esac'
  printf '#!/bin/sh\necho "nvim started" >> %q\n' "$LOG" > "$BIN/nvim"

  in_herdr_shell "nvim notes.md"
  logged restore.nvim= > /dev/null

  assert_same $'label t7 restore.nvim=\nnvim started' "$(grep -e restore.nvim= -e 'nvim started' "$LOG")"
}

function test_a_pi_line_leaves_the_nvim_session_alone() {
  in_herdr_shell "pi"
  hc_calls 2 > /dev/null

  assert_same $'label t7 restore.cmd=pi\nlabel t7 restore.cmd=' "$(cat "$LOG")"
}

function test_a_shell_outside_herdr_calls_no_hc() {
  TERMINAL_ID="" in_herdr_shell "nvim notes.md"
  sleep 0.5

  assert_file_not_exists "$LOG"
}

function test_the_shell_does_not_wait_for_the_record() {
  fake_hc 'case "$*" in *restore.cmd=*) sleep 3 ;; esac'
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

function test_a_lost_terminal_that_ran_pi_starts_pi_again_with_its_session() {
  local session="$HOME_DIR/sessions/2026-11-19_a b.jsonl"
  mkdir -p "$HOME_DIR/sessions"
  touch "$session"

  lost_terminal_with_labels "$(jq -n --arg file "$session" '{"restore.cmd": "pi", "restore.pi": $file}')"

  assert_same "pi --session $session" "$(logged '^pi ')"
}

# The label restore.nvim can stay from an earlier nvim, so a pi line must ignore it.
function test_a_lost_terminal_that_ran_pi_ignores_the_nvim_session() {
  touch "$HOME_DIR/session.jsonl" "$HOME_DIR/session.vim"

  lost_terminal_with_labels "$(jq -n --arg pi "$HOME_DIR/session.jsonl" --arg nvim "$HOME_DIR/session.vim" \
    '{"restore.cmd": "pi", "restore.pi": $pi, "restore.nvim": $nvim}')"

  assert_same "pi --session $HOME_DIR/session.jsonl" "$(logged '^pi ')"
}

# A program that fails at once must not start again in the next shell.
function test_the_relaunch_clears_the_labels_before_the_program_starts() {
  lost_terminal_with_labels '{"restore.cmd": "v notes.md"}'

  logged '^nvim ' > /dev/null

  assert_same $'get t7 --json\nlabel t7 restore.cmd= restore.pi= restore.nvim=' "$(head -2 "$LOG")"
}

function test_the_shell_stays_when_the_relaunched_program_ends() {
  lost_terminal_with_labels '{"restore.cmd": "v notes.md"}'
  logged '^nvim ' > /dev/null

  type_in_shell 'print -r -- shell-ready >> $HOME/hc.log'

  assert_same "shell-ready" "$(logged shell-ready)"
}

# The next loss of the terminal then starts the program again.
function test_the_relaunched_program_records_itself_again() {
  lost_terminal_with_labels '{"restore.cmd": "v notes.md"}'

  assert_same "label t7 restore.cmd=v notes.md" "$(logged 'restore.cmd=v')"
}

# pi writes the session file only after the first message.
function test_a_lost_terminal_that_ran_pi_with_no_session_file_continues_the_last_session() {
  lost_terminal_with_labels "$(jq -n --arg file "$HOME_DIR/none.jsonl" '{"restore.cmd": "pi", "restore.pi": $file}')"

  assert_same "pi --continue" "$(logged '^pi ')"
}

# v is an alias of nvim, so the line runs after the aliases load.
function test_a_lost_terminal_that_ran_nvim_runs_its_command_line_again() {
  lost_terminal_with_labels '{"restore.cmd": "v notes.md"}'

  assert_same "nvim notes.md" "$(logged '^nvim ')"
}

function test_a_lost_terminal_that_ran_nvim_starts_nvim_again_with_its_session() {
  local session="$HOME_DIR/sessions/t7  a.vim"
  mkdir -p "$HOME_DIR/sessions"
  touch "$session"

  lost_terminal_with_labels "$(jq -n --arg file "$session" '{"restore.cmd": "v notes.md", "restore.nvim": $file}')"

  assert_same "nvim -S $session" "$(logged '^nvim ')"
}

# A clean quit of nvim removes its session file.
function test_a_lost_terminal_that_ran_nvim_with_no_session_file_runs_its_command_line_again() {
  lost_terminal_with_labels "$(jq -n --arg file "$HOME_DIR/none.vim" '{"restore.cmd": "v notes.md", "restore.nvim": $file}')"

  assert_same "nvim notes.md" "$(logged '^nvim ')"
}

function test_a_terminal_with_no_labels_stays_a_shell() {
  lost_terminal_with_labels '{}'

  type_in_shell 'print -r -- shell-ready >> $HOME/hc.log'

  assert_same "get t7 --json" "$(logged shell-ready > /dev/null; grep -v shell-ready "$LOG")"
}

# The pi extension writes the session file to restore.pi and nothing removes it,
# so the label stays after pi ends. Only restore.cmd tells that pi still ran.
function test_a_terminal_where_pi_ended_stays_a_shell() {
  touch "$HOME_DIR/session.jsonl"
  lost_terminal_with_labels "$(jq -n --arg file "$HOME_DIR/session.jsonl" '{"restore.pi": $file}')"

  type_in_shell 'print -r -- shell-ready >> $HOME/hc.log'

  assert_same "get t7 --json" "$(logged shell-ready > /dev/null; grep -v shell-ready "$LOG")"
}

function test_a_login_shell_outside_herdr_calls_no_hc() {
  TERMINAL_ID="" lost_terminal_with_labels '{"restore.cmd": "pi"}'

  type_in_shell 'print -r -- shell-ready >> $HOME/hc.log'

  assert_same "shell-ready" "$(logged shell-ready > /dev/null; cat "$LOG")"
}

# nvim :terminal starts zsh with no -l, and a subshell has no -l either.
function test_a_shell_that_is_no_login_shell_calls_no_hc() {
  SHELL_FLAGS=-i lost_terminal_with_labels '{"restore.cmd": "pi"}'

  type_in_shell 'print -r -- shell-ready >> $HOME/hc.log'

  assert_same "shell-ready" "$(logged shell-ready > /dev/null; cat "$LOG")"
}

# Types $1 and enter into the shell in the tmux pane.
type_in_shell() {
  tmux -L "$SERVER" send-keys "$1" Enter
}

# Starts zsh in a tmux pane as Herdr starts the shell of a lost terminal: a
# login shell with the id t7, where the fake hc gives the labels $1. The zshrc
# loads the plugin before PATH holds the programs, as mise loads after it. The
# fake pi and nvim log their arguments and end. SHELL_FLAGS replaces -l.
lost_terminal_with_labels() {
  printf '{"labels": %s}\n' "$1" > "$HOME_DIR/terminal.json"
  fake_hc "[ \"\$1\" = get ] && cat $(printf %q "$HOME_DIR/terminal.json")"
  for program in nvim pi; do
    printf '#!/bin/sh\necho "%s $*" >> %q\n' "$program" "$LOG" > "$BIN/$program"
  done
  printf 'source %q\npath=(%q $path)\nalias v=nvim\nPS1="%%%% "\n' "$PLUGIN" "$BIN" > "$HOME_DIR/.zshrc"
  start_shell "${SHELL_FLAGS--l}"
}

# Starts zsh with the flags $@ in a tmux pane of 80 by 24, with the scratch
# HOME and the zshrc in it. PATH holds no mise shims, and the zshrc loads no
# config of the user. An empty TERMINAL_ID runs the shell outside Herdr.
start_shell() {
  SERVER="bashunit-$$-$RANDOM"
  tmux -L "$SERVER" -f /dev/null new-session -d -x 80 -y 24 -e HOME="$HOME_DIR" -e ZDOTDIR="$HOME_DIR" \
    -e HC_TERMINAL_ID="${TERMINAL_ID-t7}" -e PATH=/usr/bin:/bin "$HOMEBREW_ZSH $*" < /dev/null
}

# Waits at most 5 seconds until a line of the log matches $1, then prints the
# first such line.
logged() {
  for _ in {1..50}; do
    grep -m 1 -- "$1" "$LOG" 2> /dev/null && return
    sleep 0.1
  done
}

# Types each argument, then pi, into an interactive zsh in a Herdr terminal.
# pi ends on SIGTERM or SIGHUP, or after 10 seconds. The shell reads its lines
# from a fifo, so it keeps running until tear_down closes the fifo. Waits for
# pi and for the first record. +Z turns off the line editor, which reads the
# terminal and not the fifo.
shell_that_runs_pi() {
  INPUT="$HOME_DIR/input"
  printf '#!/bin/sh\necho $$ > "$HOME/pi.pid"\ntrap "exit 143" TERM HUP\nfor i in $(seq 100); do sleep 0.1; done\n' > "$BIN/pi"
  mkfifo "$INPUT"
  (
    export HC_TERMINAL_ID=t7
    HOME="$HOME_DIR" PATH="$BIN:/usr/bin:/bin" exec "$HOMEBREW_ZSH" -f -i +Z < "$INPUT" > /dev/null 2>&1
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
# shell outside Herdr. +Z turns off the line editor, which reads the terminal
# and not the pipe.
in_herdr_shell() {
  (
    unset HC_TERMINAL_ID
    [[ -n ${TERMINAL_ID-t7} ]] && export HC_TERMINAL_ID=${TERMINAL_ID-t7}
    printf '%s\n' "source ${PLUGIN@Q}" "$@" |
      HOME="$HOME_DIR" PATH="$BIN:/usr/bin:/bin" "$HOMEBREW_ZSH" -f -i +Z > /dev/null 2>&1
  )
}

# The hc of the user is not on PATH, so the plugin runs ~/.local/bin/hc. This
# fake logs its arguments. $1 is a shell line that runs before the log.
fake_hc() {
  printf '#!/bin/sh\n%s\necho "$*" >> %q\n' "$1" "$LOG" > "$HOME_DIR/.local/bin/hc"
  chmod +x "$HOME_DIR/.local/bin/hc"
}

# Waits at most 5 seconds until the fake hc logged $1 calls that set
# restore.cmd, then prints them. The plugin runs these calls in the background.
hc_calls() {
  for _ in {1..50}; do
    [[ $(grep -c restore.cmd= "$LOG" 2> /dev/null) -ge $1 ]] && break
    sleep 0.1
  done
  grep restore.cmd= "$LOG" 2> /dev/null
}
