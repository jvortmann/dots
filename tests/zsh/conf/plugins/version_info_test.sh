#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
ZSHRC="$ROOT/zsh/zshrc"
PLUGIN="$ROOT/zsh/conf/plugins/version_info.zsh"
HOMEBREW_ZSH=/opt/homebrew/bin/zsh

# Run a command in zsh started as a terminal starts it, where grg and mise
# come from the mise shims. Only the command's own stderr is kept.
in_terminal_zsh() {
  local zdotdir
  zdotdir=$(bashunit::temp_dir "zdotdir")
  printf 'source %q\n' "$ZSHRC" > "$zdotdir/.zshrc"
  (cd "$FOLDER" && env -i HOME="$HOME" USER="$USER" TERM=xterm-256color ZDOTDIR="$zdotdir" \
    SHELL="$HOMEBREW_ZSH" PATH=/usr/bin:/bin:/usr/sbin:/sbin "$HOMEBREW_ZSH" -l -i -c "$1" 2> /dev/null)
}

function set_up() {
  [[ -f $PLUGIN ]] || bashunit::fail "missing the file under test: $PLUGIN"
  [[ -x $HOMEBREW_ZSH ]] || bashunit::skip "needs Homebrew zsh"
  command -v mise > /dev/null || bashunit::skip "needs mise"
  FOLDER=$(bashunit::temp_dir "version_info")
}

function test_language_info_prints_nothing_where_mise_does_not_trust_the_config() {
  printf '[tools]\nnode = "20"\n\n[env]\nGREETING = "{{ env.HOME }}"\n' > "$FOLDER/mise.toml"

  assert_same "" "$(in_terminal_zsh 'language_info 2>&1')"
}

function test_language_info_shows_the_local_tools_without_running_grep() {
  printf '[tools]\nnode = "20"\n' > "$FOLDER/mise.toml"

  local output
  output=$(in_terminal_zsh 'function grep { print GREP_CALLED; }; language_info')

  assert_not_contains "GREP_CALLED" "$output"
  assert_contains "[node:20" "$output"
}
