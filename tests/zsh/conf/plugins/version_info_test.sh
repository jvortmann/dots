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

function test_the_right_prompt_runs_mise_once_for_two_draws_in_one_folder() {
  printf '[tools]\nnode = "20"\n' > "$FOLDER/mise.toml"

  local calls output
  calls=$(bashunit::temp_file "mise_calls")
  output=$(in_terminal_zsh "$(count_mise "$calls"); $DRAW; $DRAW")

  assert_contains "[node:20" "$output"
  assert_same "1" "$(wc -l < "$calls" | tr -d ' ')"
}

function test_the_right_prompt_shows_a_new_version_after_the_config_changes() {
  printf '[tools]\nnode = "20"\n' > "$FOLDER/mise.toml"
  touch -t 202001010000 "$FOLDER/mise.toml"
  printf '[tools]\npython = "3.10"\n' > "$FOLDER/next.toml"

  local output
  output=$(in_terminal_zsh "$DRAW > /dev/null; mv next.toml mise.toml; $DRAW")

  assert_contains "[python:3.10" "$output"
}

function test_the_right_prompt_shows_a_new_version_after_an_install() {
  local data version
  data=$(bashunit::temp_dir "mise_data")
  version=$(bashunit::temp_file "version")
  mkdir -p "$data/installs/node/26.10.0"
  touch -t 202001010000 "$data/installs/node"
  printf '26.10.0' > "$version"
  local stub="export MISE_DATA_DIR=$data; function mise { print \"node \$(<$version) ~/.config/mise/config.toml latest\"; }"
  local install="mkdir $data/installs/node/26.11.0; print -n 26.11.0 > $version"

  local output
  output=$(in_terminal_zsh "$stub; $DRAW > /dev/null; $install; $DRAW")

  assert_contains "[node:26.11.0]" "$output"
}

function test_the_right_prompt_shows_the_tools_of_the_folder_it_moves_to() {
  mkdir "$FOLDER/node" "$FOLDER/python"
  printf '[tools]\nnode = "20"\n' > "$FOLDER/node/mise.toml"
  printf '[tools]\npython = "3.10"\n' > "$FOLDER/python/mise.toml"

  local output
  output=$(in_terminal_zsh "cd node; $DRAW > /dev/null; cd ../python; $DRAW")

  assert_contains "[python:3.10" "$output"
}

# One prompt draw, as zsh does it: the precmd functions, then the right prompt.
DRAW='for f in $precmd_functions; do $f; done; print -r -- "${(e)RPROMPT}"'

# A mise that writes one line to a file for each call, then runs the real one.
count_mise() {
  printf 'function mise { print $1 >> %q; command mise "$@"; }' "$1"
}
