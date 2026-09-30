#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
ZSHRC="$ROOT/zsh/zshrc"
PLUGIN="$ROOT/zsh/conf/plugins/greprip.zsh"
HOMEBREW_ZSH=/opt/homebrew/bin/zsh

# Run a command in an interactive zsh that reads the repository zshrc, from a
# git repository with one ignored file.
in_interactive_zsh() {
  local zdotdir
  zdotdir=$(bashunit::temp_dir "zdotdir")
  printf 'source %q\n' "$ZSHRC" > "$zdotdir/.zshrc"
  (cd "$REPO" && ZDOTDIR="$zdotdir" RIPGREP_CONFIG_PATH= "$HOMEBREW_ZSH" -i -c "$1" 2> /dev/null)
}

# The same, started as a terminal starts zsh: a login shell with a short PATH.
in_terminal_zsh() {
  local zdotdir
  zdotdir=$(bashunit::temp_dir "zdotdir")
  printf 'source %q\n' "$ZSHRC" > "$zdotdir/.zshrc"
  (cd "$REPO" && env -i HOME="$HOME" USER="$USER" TERM=xterm-256color ZDOTDIR="$zdotdir" \
    SHELL="$HOMEBREW_ZSH" PATH=/usr/bin:/bin:/usr/sbin:/sbin "$HOMEBREW_ZSH" -l -i -c "$1" 2> /dev/null)
}

function set_up() {
  [[ -f $PLUGIN ]] || bashunit::fail "missing the file under test: $PLUGIN"
  [[ -x $HOMEBREW_ZSH ]] || bashunit::skip "needs Homebrew zsh"
  command -v grg > /dev/null || bashunit::skip "needs grg"
  REPO=$(bashunit::temp_dir "greprip")
  git -C "$REPO" init -q
  mkdir -p "$REPO/src" "$REPO/build"
  printf 'Alpha foo\nbeta Foo\ngamma\n' > "$REPO/src/one.ts"
  printf 'foo\n' > "$REPO/build/out.ts"
  printf 'build/\n' > "$REPO/.gitignore"
}

function test_grep_in_the_interactive_shell_skips_ignored_files_and_ignores_case() {
  assert_same "./src/one.ts:1:Alpha foo
./src/one.ts:2:beta Foo" "$(in_interactive_zsh 'grep -rn FOO .')"
}

function test_grep_in_a_new_terminal_skips_ignored_files() {
  assert_same "./src/one.ts:1:Alpha foo
./src/one.ts:2:beta Foo" "$(in_terminal_zsh 'grep -rn FOO .')"
}
