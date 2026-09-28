#!/bin/bash

ZSHRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/zshrc"
HOMEBREW_ZSH=/opt/homebrew/bin/zsh

# Start zsh the way a terminal does, as an interactive login shell with the
# SHELL and the short PATH it passes in, and read the repository zshrc. Print
# what the shell holds after startup.
TERMINAL_PATH=/usr/bin:/bin:/usr/sbin:/sbin

variable_after_startup() {
  local name=$1 zdotdir
  zdotdir=$(bashunit::temp_dir "zshrc")
  printf 'source %q\n' "$ZSHRC" > "$zdotdir/.zshrc"
  ZDOTDIR="$zdotdir" SHELL="$HOMEBREW_ZSH" PATH="$TERMINAL_PATH" \
    "$HOMEBREW_ZSH" -l -i -c "print -r -- \$$name" 2> /dev/null | tail -1
}

function set_up() {
  [[ -x $HOMEBREW_ZSH ]] || bashunit::skip "needs Homebrew zsh"
}

function test_keeps_the_shell_the_terminal_started() {
  assert_same "$HOMEBREW_ZSH" "$(variable_after_startup SHELL)"
}
