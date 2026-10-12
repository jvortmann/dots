#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ZSHRC="$ROOT/zsh/zshrc"
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
  [[ -f $ZSHRC ]] || bashunit::fail "missing the file under test: $ZSHRC"
  [[ -x $HOMEBREW_ZSH ]] || bashunit::skip "needs Homebrew zsh"
}

function test_keeps_the_shell_the_terminal_started() {
  assert_same "$HOMEBREW_ZSH" "$(variable_after_startup SHELL)"
}

function test_grep_and_find_in_a_new_terminal_read_ignored_files() {
  local repo
  repo=$(bashunit::temp_dir "ignored")
  git -C "$repo" init -q
  mkdir "$repo/build"
  printf 'foo\n' > "$repo/build/out.ts"
  printf 'build/\n' > "$repo/.gitignore"

  assert_same "./build/out.ts:foo
./build/out.ts" "$(in_new_terminal "$repo" "grep -r foo .; find . -name out.ts")"
}

# Run a command in a new terminal shell, from the given folder.
in_new_terminal() {
  local zdotdir
  zdotdir=$(bashunit::temp_dir "zshrc")
  printf 'source %q\n' "$ZSHRC" > "$zdotdir/.zshrc"
  (cd "$1" && ZDOTDIR="$zdotdir" SHELL="$HOMEBREW_ZSH" PATH="$TERMINAL_PATH" \
    "$HOMEBREW_ZSH" -l -i -c "$2" 2> /dev/null)
}
