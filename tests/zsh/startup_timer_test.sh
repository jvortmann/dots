#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ZSHENV="$ROOT/zsh/zshenv"
ZSHRC="$ROOT/zsh/zshrc"
HOMEBREW_ZSH=/opt/homebrew/bin/zsh

function set_up() {
  [[ -f $ZSHRC ]] || bashunit::fail "missing the file under test: $ZSHRC"
  [[ -x $HOMEBREW_ZSH ]] || bashunit::skip "needs Homebrew zsh"
  ZSHENV_EXTRA=""
  ZSHRC_EXTRA=""
  FOLDER=$(bashunit::temp_dir "startup_timer")
}

function test_the_first_prompt_time_counts_the_files_read_before_the_zshrc() {
  ZSHENV_EXTRA="sleep 0.3"

  assert_greater_or_equal_than 300 "$(at_prompts 'print -r -- $LAST_COMMAND_TIME')"
}

function test_the_first_prompt_time_counts_the_precmd_functions() {
  ZSHRC_EXTRA="function mise { sleep 0.3; }"

  assert_greater_or_equal_than 300 "$(at_prompts 'print -r -- $LAST_COMMAND_TIME')"
}

function test_the_first_prompt_time_counts_the_git_work_of_the_prompt() {
  ZSHRC_EXTRA="function git { sleep 0.3; }"

  assert_greater_or_equal_than 300 "$(at_prompts 'print -r -- $LAST_COMMAND_TIME')"
}

function test_the_prompt_shows_the_user_the_host_and_the_folder() {
  local prompt
  prompt=$(at_prompts 'print -r -- "${(%)${(e)PROMPT}}"' | sed $'s/\e[[(][0-9;]*[mB]//g')

  assert_same "$USER@$(hostname -s) ${FOLDER##*/}  ∴ " "$prompt"
}

# zsh reads the command lines from a pipe and can have no terminal, so the test
# sets TTY. The time tracker then records each command as it does in a terminal.
function test_a_later_prompt_shows_the_time_of_the_last_command() {
  ZSHENV_EXTRA="sleep 0.3"

  assert_less_than 300 "$(at_prompts 'TTY=/dev/tty' 'true' 'print -r -- $LAST_COMMAND_TIME')"
}

function test_the_prompt_after_reading_the_zshrc_again_shows_the_time_of_that_command() {
  ZSHENV_EXTRA="sleep 0.3"

  assert_less_than 300 "$(at_prompts 'TTY=/dev/tty' 'source $ZDOTDIR/.zshrc' 'print -r -- $LAST_COMMAND_TIME')"
}

function test_startup_times_lists_each_phase_and_the_total() {
  assert_same "system files
init.zsh
after init.zsh
precmd
total" "$(at_prompts startup-times | phase_names)"
}

function test_startup_times_starts_at_init_zsh_when_the_shell_read_no_zshenv() {
  ZSHENV=/dev/null

  assert_same "init.zsh
after init.zsh
precmd
total" "$(at_prompts startup-times | phase_names)"
}

function test_startup_times_counts_a_precmd_function_added_before_the_zshrc_in_the_precmd_phase() {
  ZSHENV_EXTRA="function slow { sleep 0.3; }; precmd_functions=(slow)"

  assert_greater_or_equal_than 300 "$(at_prompts startup-times | phase_ms precmd)"
}

function test_startup_times_at_a_later_prompt_still_shows_the_first_prompt() {
  ZSHENV_EXTRA="function slow { sleep 0.3; }; precmd_functions=(slow)"

  assert_greater_or_equal_than 300 "$(at_prompts true startup-times | phase_ms precmd)"
}

function test_startup_times_after_reading_the_zshrc_again_shows_no_negative_phase() {
  assert_not_contains " -" "$(at_prompts 'source $ZDOTDIR/.zshrc' startup-times)"
}

# Start zsh as a terminal starts it, with the repository zshenv and zshrc, and
# type each argument as one command line. A command line runs after the prompt
# before it, so the first one sees the state of the first prompt.
# ZSHENV_EXTRA and ZSHRC_EXTRA add lines after the repository files. +Z turns
# off the line editor, which reads the terminal and not the pipe.
at_prompts() {
  local zdotdir
  zdotdir=$(bashunit::temp_dir "zdotdir")
  printf 'source %q\n%s\n' "$ZSHENV" "$ZSHENV_EXTRA" > "$zdotdir/.zshenv"
  printf 'source %q\n%s\n' "$ZSHRC" "$ZSHRC_EXTRA" > "$zdotdir/.zshrc"
  printf '%s\n' "$@" | (cd "$FOLDER" && env -i HOME="$HOME" USER="$USER" \
    TERM=xterm-256color ZDOTDIR="$zdotdir" SHELL="$HOMEBREW_ZSH" \
    PATH=/usr/bin:/bin:/usr/sbin:/sbin "$HOMEBREW_ZSH" -l -i +Z 2> /dev/null)
}

# The name of each line that startup-times prints, without its time.
phase_names() {
  sed -E 's/ +[0-9.]+ ms$//'
}

# The whole milliseconds of one phase that startup-times prints.
phase_ms() {
  sed -nE "s/^$1 +(-?[0-9]+)\.[0-9] ms$/\1/p"
}
