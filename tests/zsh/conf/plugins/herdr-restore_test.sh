#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
PLUGIN="$ROOT/zsh/conf/plugins/herdr-restore.zsh"
HOMEBREW_ZSH=/opt/homebrew/bin/zsh
# shellcheck source=../../../fakes/fakes.sh
source "$ROOT/tests/fakes/fakes.sh"
# shellcheck source=../../../tmux_shell.sh
source "$ROOT/tests/tmux_shell.sh"

# Shell code for a call of the fake hc that blocks. It opens the gate of hc,
# reports, and reads one line from the gate. release writes that line. When the
# test ends first, the gate closes and the read ends. The open does not block,
# so a call that comes after the test ended goes on at once.
# shellcheck disable=SC2016
HOLD='perl -MFcntl -e '\''sysopen(my $gate, "$ARGV[0].gate", O_RDONLY | O_NONBLOCK) or exit;
  fcntl($gate, F_SETFL, 0);
  if (sysopen(my $channel, "$ARGV[0].channel", O_WRONLY | O_NONBLOCK)) { syswrite($channel, "done\n") }
  alarm 5; my $line = <$gate>'\'' "$0"'

# The channel of each fake, by its name.
declare -gA CHANNEL

function set_up() {
  INPUT=""
  SERVER=""
  FAKE_GATE_FD=""
  CHANNEL=()
  [[ -f $PLUGIN ]] || bashunit::fail "missing the file under test: $PLUGIN"
  [[ -x $HOMEBREW_ZSH ]] || bashunit::skip "needs Homebrew zsh"
  command -v tmux > /dev/null || bashunit::skip "needs tmux"
  HOME_DIR=$(bashunit::temp_dir "home")
  BIN=$(bashunit::temp_dir "bin")
  LOG="$HOME_DIR/hc.log"
  fake_hc ""
  for program in nvim vim vi n pi pip; do
    fake_program "$BIN" "$program" ""
  done
}

# Ends the tmux server of the test, and the shell in it. A typed exit can
# stay unread, and the server then keeps running. The server leaves its
# socket file, so tear_down removes it.
function tear_down() {
  if [[ -n $SERVER ]]; then
    tmux -L "$SERVER" kill-server 2> /dev/null
    rm -f "${TMUX_TMPDIR:-/tmp}/tmux-$(id -u)/$SERVER"
  fi
  [[ -n $INPUT ]] || return 0
  [[ -s $HOME_DIR/pi.pid ]] && kill "$(cat "$HOME_DIR/pi.pid")" 2> /dev/null || true
  exec 3>&-
}

function test_a_herdr_terminal_records_the_nvim_command_line_while_it_runs() {
  in_herdr_shell "nvim notes.md"

  assert_same "label t7 restore.cmd=nvim notes.md" "$(hc_calls | head -1)"
}

function test_the_record_goes_when_the_command_ends() {
  in_herdr_shell "nvim notes.md"

  assert_same $'label t7 restore.cmd=nvim notes.md\nlabel t7 restore.cmd=' "$(hc_calls)"
}

# @data_provider the_other_names_of_nvim
function test_a_herdr_terminal_records_the_other_names_of_nvim() {
  in_herdr_shell "$1 notes.md"

  assert_same "label t7 restore.cmd=$1 notes.md" "$(hc_calls | head -1)"
}

function the_other_names_of_nvim() {
  bashunit::data_set vim
  bashunit::data_set vi
  bashunit::data_set n
}

function test_a_herdr_terminal_records_a_command_with_no_arguments() {
  in_herdr_shell "pi"

  assert_same "label t7 restore.cmd=pi" "$(hc_calls | head -1)"
}

# The pi line comes last. Had pip called hc, the first logged call would be
# the one of pip.
function test_another_command_leaves_the_labels_alone() {
  in_herdr_shell "pip list" "pi"

  assert_same "label t7 restore.cmd=pi" "$(head -1 "$LOG")"
}

# An nvim that saves no session, such as nvim --clean, must not leave the
# label of an earlier nvim. An nvim that saves one labels itself again.
function test_a_herdr_terminal_clears_the_nvim_session_when_nvim_starts() {
  in_herdr_shell "nvim notes.md"

  assert_same "label t7 restore.nvim=" "$(logged restore.nvim=)"
}

# nvim labels itself at start, so a clear that lands later removes that label.
# The clear of the nvim session blocks until the test releases it. The test
# waits until the record and this clear reached hc. Had the shell not waited
# for the clear, nvim would start in that time.
function test_the_nvim_session_clears_before_nvim_starts() {
  fake_hc "case \"\$*\" in *restore.nvim=) $HOLD ;; esac"
  open_gate "$HOME_DIR/.local/bin/hc"
  listen_to hc
  fake_program "$BIN" nvim "echo 'nvim started' >> $(printf %q "$LOG")"

  in_herdr_shell "nvim notes.md" &
  reported hc 2
  release
  wait $!

  assert_same $'label t7 restore.nvim=\nnvim started' "$(grep -e restore.nvim= -e 'nvim started' "$LOG")"
}

function test_a_pi_line_leaves_the_nvim_session_alone() {
  in_herdr_shell "pi"

  assert_same $'label t7 restore.cmd=pi\nlabel t7 restore.cmd=' "$(cat "$LOG")"
}

function test_an_nvim_line_runs_with_the_mark_of_the_shell() {
  fakes_that_log_the_mark

  in_herdr_shell "nvim notes.md"

  assert_same "nvim HERDR_RESTORE_NVIM=1" "$(cat "$MARKS")"
}

# @data_provider commands_that_are_not_nvim
function test_a_command_after_an_nvim_line_runs_without_the_mark() {
  fakes_that_log_the_mark

  in_herdr_shell "nvim notes.md" "$1"

  assert_same "$1 HERDR_RESTORE_NVIM=" "$(tail -1 "$MARKS")"
}

function commands_that_are_not_nvim() {
  bashunit::data_set pi
  bashunit::data_set pip
}

function test_a_shell_outside_herdr_runs_nvim_without_the_mark() {
  fakes_that_log_the_mark

  TERMINAL_ID="" in_herdr_shell "nvim notes.md"

  assert_same "nvim HERDR_RESTORE_NVIM=" "$(cat "$MARKS")"
}

function test_a_shell_outside_herdr_calls_no_hc() {
  TERMINAL_ID="" in_herdr_shell "nvim notes.md"

  assert_file_not_exists "$LOG"
}

# The record blocks until the test ends. A shell that waits for it ends only
# when the read of the gate stops after 5 seconds.
function test_the_shell_does_not_wait_for_the_record() {
  fake_hc "case \"\$*\" in *restore.cmd=?*) $HOLD ;; esac"
  open_gate "$HOME_DIR/.local/bin/hc"
  SECONDS=0

  herdr_zsh "nvim notes.md" > /dev/null

  assert_less_than 3 "$SECONDS"
}

# The record blocks, so a clear that does not wait for it runs first and leaves
# the record of a command that already ended. The fake sleep reports when the
# clear waits, and only then the test lets the record go.
function test_a_command_that_ends_at_once_leaves_no_record() {
  fake_hc "case \"\$*\" in *restore.cmd=?*) $HOLD ;; esac"
  open_gate "$HOME_DIR/.local/bin/hc"
  fake_sleep
  listen_to sleep

  in_herdr_shell "nvim --version" &
  reported sleep
  release
  wait $!

  assert_same $'label t7 restore.cmd=nvim --version\nlabel t7 restore.cmd=' "$(hc_calls)"
}

# A shutdown sends a signal to the shell and to pi: SIGTERM at a reboot, SIGHUP
# when the terminal closes. For each signal, the record must stay.
# @data_provider shutdown_signals
function test_a_shell_that_a_shutdown_ends_keeps_the_record() {
  shell_that_runs_pi

  kill "-$1" "$SHELL_PID" "$(cat "$HOME_DIR/pi.pid")"
  shell_ended

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

  printf '%s\n' "nvim notes.md" >&3
  shell_ended

  assert_same $'label t7 restore.cmd=pi\nlabel t7 restore.cmd=nvim notes.md\nlabel t7 restore.cmd=' "$(hc_calls)"
}

# The clear blocks. A record of pi that does not wait for it runs first, and the
# clear then removes the record of pi while pi runs. Before pi runs, the first
# line calls hc three times: the record, the clear of the nvim session and the
# clear. The fake sleep reports when the record of pi waits, and only then the
# test lets the clear go.
function test_the_clear_of_a_command_does_not_remove_the_record_of_the_next() {
  fake_hc "case \"\$*\" in *restore.cmd=) $HOLD ;; esac"
  open_gate "$HOME_DIR/.local/bin/hc"
  fake_sleep

  shell_that_runs_pi "nvim --version"
  reported hc 2
  listen_to sleep
  reported sleep
  release
  reported hc 2

  assert_same $'label t7 restore.cmd=nvim --version\nlabel t7 restore.cmd=\nlabel t7 restore.cmd=pi' "$(hc_calls)"
}

function test_a_lost_terminal_that_ran_pi_starts_pi_again_with_its_session() {
  local session="$HOME_DIR/sessions/2026-11-19_a b.jsonl"
  mkdir -p "$HOME_DIR/sessions"
  touch "$session"

  lost_terminal_with_labels "$(jq -n --arg file "$session" '{"restore.cmd": "pi", "restore.pi": $file}')"
  reported pi

  assert_same "pi --session $session" "$(logged '^pi ')"
}

# The label restore.nvim can stay from an earlier nvim, so a pi line must ignore it.
function test_a_lost_terminal_that_ran_pi_ignores_the_nvim_session() {
  touch "$HOME_DIR/session.jsonl" "$HOME_DIR/session.vim"

  lost_terminal_with_labels "$(jq -n --arg pi "$HOME_DIR/session.jsonl" --arg nvim "$HOME_DIR/session.vim" \
    '{"restore.cmd": "pi", "restore.pi": $pi, "restore.nvim": $nvim}')"
  reported pi

  assert_same "pi --session $HOME_DIR/session.jsonl" "$(logged '^pi ')"
}

# A program that fails at once must not start again in the next shell.
function test_the_relaunch_clears_the_labels_before_the_program_starts() {
  lost_terminal_with_labels '{"restore.cmd": "v notes.md"}'

  reported nvim

  assert_same $'get t7 --json\nlabel t7 restore.cmd= restore.pi= restore.nvim=' "$(head -2 "$LOG")"
}

function test_the_shell_stays_when_the_relaunched_program_ends() {
  lost_terminal_with_labels '{"restore.cmd": "v notes.md"}'
  reported nvim

  run_in_shell 'print -r -- shell-ready >> $HOME/hc.log'

  assert_same "shell-ready" "$(logged shell-ready)"
}

# The next loss of the terminal then starts the program again. The relaunch
# calls hc five times: the read, the clear of the labels, the record, the clear
# of the nvim session and the clear of the record.
function test_the_relaunched_program_records_itself_again() {
  lost_terminal_with_labels '{"restore.cmd": "v notes.md"}'
  reported hc 5

  assert_same "label t7 restore.cmd=v notes.md" "$(logged 'restore.cmd=v')"
}

# pi writes the session file only after the first message.
function test_a_lost_terminal_that_ran_pi_with_no_session_file_continues_the_last_session() {
  lost_terminal_with_labels "$(jq -n --arg file "$HOME_DIR/none.jsonl" '{"restore.cmd": "pi", "restore.pi": $file}')"
  reported pi

  assert_same "pi --continue" "$(logged '^pi ')"
}

# v is an alias of nvim, so the line runs after the aliases load.
function test_a_lost_terminal_that_ran_nvim_runs_its_command_line_again() {
  lost_terminal_with_labels '{"restore.cmd": "v notes.md"}'
  reported nvim

  assert_same "nvim notes.md" "$(logged '^nvim ')"
}

function test_a_lost_terminal_that_ran_nvim_starts_nvim_again_with_its_session() {
  local session="$HOME_DIR/sessions/t7  a.vim"
  mkdir -p "$HOME_DIR/sessions"
  touch "$session"

  lost_terminal_with_labels "$(jq -n --arg file "$session" '{"restore.cmd": "v notes.md", "restore.nvim": $file}')"
  reported nvim

  assert_same "nvim -S $session" "$(logged '^nvim ')"
}

# A clean quit of nvim removes its session file.
function test_a_lost_terminal_that_ran_nvim_with_no_session_file_runs_its_command_line_again() {
  lost_terminal_with_labels "$(jq -n --arg file "$HOME_DIR/none.vim" '{"restore.cmd": "v notes.md", "restore.nvim": $file}')"
  reported nvim

  assert_same "nvim notes.md" "$(logged '^nvim ')"
}

function test_a_terminal_with_no_labels_stays_a_shell() {
  lost_terminal_with_labels '{}'

  run_in_shell 'print -r -- shell-ready >> $HOME/hc.log'

  assert_same "get t7 --json" "$(grep -v shell-ready "$LOG")"
}

# The pi extension writes the session file to restore.pi and nothing removes it,
# so the label stays after pi ends. Only restore.cmd tells that pi still ran.
function test_a_terminal_where_pi_ended_stays_a_shell() {
  touch "$HOME_DIR/session.jsonl"
  lost_terminal_with_labels "$(jq -n --arg file "$HOME_DIR/session.jsonl" '{"restore.pi": $file}')"

  run_in_shell 'print -r -- shell-ready >> $HOME/hc.log'

  assert_same "get t7 --json" "$(grep -v shell-ready "$LOG")"
}

function test_a_login_shell_outside_herdr_calls_no_hc() {
  TERMINAL_ID="" lost_terminal_with_labels '{"restore.cmd": "pi"}'

  run_in_shell 'print -r -- shell-ready >> $HOME/hc.log'

  assert_same "shell-ready" "$(cat "$LOG")"
}

# nvim :terminal starts zsh with no -l, and a subshell has no -l either.
function test_a_shell_that_is_no_login_shell_calls_no_hc() {
  SHELL_FLAGS=-i lost_terminal_with_labels '{"restore.cmd": "pi"}'

  run_in_shell 'print -r -- shell-ready >> $HOME/hc.log'

  assert_same "shell-ready" "$(cat "$LOG")"
}

# The hc of the user is not on PATH, so the plugin runs ~/.local/bin/hc. This
# fake logs its arguments and reports. $1 is a shell line that runs before the
# log.
fake_hc() {
  fake_program "$HOME_DIR/.local/bin" hc "$1"$'\n'"echo \"\$*\" >> $(printf %q "$LOG")"$'\n'"$FAKE_REPORT"
}

# Puts fakes of nvim, pi and pip on PATH that log their name and the value of
# HERDR_RESTORE_NVIM to the file MARKS.
fakes_that_log_the_mark() {
  MARKS="$HOME_DIR/marks.log"
  for program in nvim pi pip; do
    fake_program "$BIN" "$program" "echo \"$program HERDR_RESTORE_NVIM=\${HERDR_RESTORE_NVIM-}\" >> $(printf %q "$MARKS")"
  done
}

# Opens the channel of the fake $1 (hc, nvim, pi or sleep), so that the test
# can read its reports. A fake reports only while its channel is open.
listen_to() {
  [[ -z ${CHANNEL[$1]-} ]] || return 0
  if [[ $1 == hc ]]; then
    open_channel "$HOME_DIR/.local/bin/hc"
  else
    open_channel "$BIN/$1"
  fi
  CHANNEL[$1]=$FAKE_CHANNEL
}

# Returns when the fake $1 reported $2 more calls. $2 is 1 when it is empty.
reported() {
  FAKE_CHANNEL=${CHANNEL[$1]} read_reports "${2:-1}"
}

# Runs each argument as one command line in an interactive zsh that loads the
# plugin, as in herdr_zsh. Returns when zsh and each write of hc that it started
# in the background end. Each of them holds the output pipe of zsh until it
# ends, and read_to_end reads that pipe to its end.
in_herdr_shell() {
  herdr_zsh "$@" | read_to_end
}

# Types each argument as one command line into an interactive zsh that loads
# the plugin, in a Herdr terminal with the id t7, and returns when zsh ends. An
# empty TERMINAL_ID runs the shell outside Herdr. +Z turns off the line editor,
# which reads the terminal and not the pipe.
herdr_zsh() {
  (
    close_gate
    unset HC_TERMINAL_ID
    [[ -n ${TERMINAL_ID-t7} ]] && export HC_TERMINAL_ID=${TERMINAL_ID-t7}
    printf '%s\n' "source ${PLUGIN@Q}" "$@" |
      HOME="$HOME_DIR" PATH="$BIN:/usr/bin:/bin" "$HOMEBREW_ZSH" -f -i +Z 2>&1
  )
}

# The shell does not get the gate of the test. Its jobs in the background would
# keep the gate open after the test ends, and a held call of hc would block.
close_gate() {
  [[ -z $FAKE_GATE_FD ]] || exec {FAKE_GATE_FD}>&-
}

# Writes the line that lets the held call of hc go.
release() {
  echo >&"$FAKE_GATE_FD"
}

# Puts a fake sleep on PATH. The plugin runs sleep while a write of hc waits
# for the write before it. The fake reports, then sleeps as the real one does.
fake_sleep() {
  fake_program "$BIN" sleep "$FAKE_REPORT"$'\nexec /bin/sleep "$@"'
}

# Types each argument, then pi, into an interactive zsh in a Herdr terminal.
# pi stays until a signal ends it. The shell reads its lines from a fifo, so it
# keeps running until shell_ended or tear_down closes the fifo. Returns when pi
# runs and the first call of hc ended. +Z turns off the line editor, which
# reads the terminal and not the fifo.
shell_that_runs_pi() {
  INPUT="$HOME_DIR/input"
  fake_program "$BIN" pi "echo \$\$ > \"\$HOME/pi.pid\""$'\n'"$FAKE_REPORT"$'\n'"$FAKE_STAY"
  listen_to pi
  listen_to hc
  mkfifo "$INPUT"
  exec {SHELL_OUT}< <(
    close_gate
    export HC_TERMINAL_ID=t7
    HOME="$HOME_DIR" PATH="$BIN:/usr/bin:/bin" exec "$HOMEBREW_ZSH" -f -i +Z < "$INPUT" 2>&1
  )
  SHELL_PID=$!
  exec 3> "$INPUT"
  printf '%s\n' "source ${PLUGIN@Q}" "$@" pi >&3
  reported pi
  reported hc
}

# Closes the input of the shell from shell_that_runs_pi, so zsh ends. Returns
# when zsh and each write of hc that it started in the background end.
shell_ended() {
  exec 3>&-
  read_to_end <&"$SHELL_OUT"
}

# Reads its input to the end. It stops after 5 seconds, so a job that never
# ends cannot hang the suite.
read_to_end() {
  perl -e 'alarm 5; exec @ARGV' cat > /dev/null
}

# Starts zsh in a tmux pane as Herdr starts the shell of a lost terminal: a
# login shell with the id t7, where the fake hc gives the labels $1. The zshrc
# loads the plugin before PATH holds the programs, as mise loads after it. The
# fake pi and nvim log their arguments, report and end. SHELL_FLAGS replaces -l.
lost_terminal_with_labels() {
  printf '{"labels": %s}\n' "$1" > "$HOME_DIR/terminal.json"
  fake_hc "[ \"\$1\" = get ] && cat $(printf %q "$HOME_DIR/terminal.json")"
  for program in nvim pi; do
    fake_program "$BIN" "$program" "echo \"$program \$*\" >> $(printf %q "$LOG")"$'\n'"$FAKE_REPORT"
    listen_to "$program"
  done
  listen_to hc
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

# Prints the first line of the log that matches $1.
logged() {
  grep -m 1 -- "$1" "$LOG" 2> /dev/null
}

# Prints the calls of the fake hc that set or clear restore.cmd.
hc_calls() {
  grep restore.cmd= "$LOG" 2> /dev/null
}
