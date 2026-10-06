#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
ZSHRC="$ROOT/zsh/zshrc"
PLUGIN="$ROOT/zsh/conf/plugins/gitstatus.zsh"
HOMEBREW_ZSH=/opt/homebrew/bin/zsh

# Run a command in zsh started as a terminal starts it, in the test repository.
in_terminal_zsh() {
  local zdotdir
  zdotdir=$(bashunit::temp_dir "zdotdir")
  printf 'source %q\n' "$ZSHRC" > "$zdotdir/.zshrc"
  (cd "$REPO" && env -i HOME="$HOME" USER="$USER" TERM=xterm-256color ZDOTDIR="$zdotdir" \
    SHELL="$HOMEBREW_ZSH" PATH=/usr/bin:/bin:/usr/sbin:/sbin "$HOMEBREW_ZSH" -l -i -c "$1" 2> /dev/null)
}

# The names of the state marks that git_status shows, in a fixed order.
MARKS='s=$(git_status 2>&1); for m in MERGING DELETED UNTRACKED MODIFIED STAGED; do
  v=_GIT_PROMPT_$m; [[ $s == *"${(P)v}"* ]] && print -n "$m "; done; [[ $s == *ERROR* ]] && print -n ERROR'

function set_up() {
  [[ -f $PLUGIN ]] || bashunit::fail "missing the file under test: $PLUGIN"
  [[ -x $HOMEBREW_ZSH ]] || bashunit::skip "needs Homebrew zsh"
  REPO=$(bashunit::temp_dir "gitstatus")
  in_repo init -q -b main
  printf 'one\n' > "$REPO/kept.txt"
  printf 'two\n' > "$REPO/gone.txt"
  in_repo add kept.txt gone.txt
  in_repo commit -q -m "Start"
}

function test_git_status_shows_no_mark_in_a_clean_repository() {
  assert_same "" "$(in_terminal_zsh "$MARKS")"
}

function test_git_status_marks_an_untracked_file() {
  printf 'new\n' > "$REPO/new.txt"

  assert_same "UNTRACKED " "$(in_terminal_zsh "$MARKS")"
}

function test_git_status_marks_a_modified_file() {
  printf 'changed\n' > "$REPO/kept.txt"

  assert_same "MODIFIED " "$(in_terminal_zsh "$MARKS")"
}

function test_git_status_marks_a_deleted_file() {
  rm "$REPO/gone.txt"

  assert_same "DELETED " "$(in_terminal_zsh "$MARKS")"
}

function test_git_status_marks_a_staged_file() {
  printf 'changed\n' > "$REPO/kept.txt"
  in_repo add kept.txt

  assert_same "STAGED " "$(in_terminal_zsh "$MARKS")"
}

function test_git_status_marks_a_merge_conflict() {
  in_repo switch -q -c side
  printf 'side\n' > "$REPO/kept.txt"
  in_repo commit -q -am "Side"
  in_repo switch -q main
  printf 'main\n' > "$REPO/kept.txt"
  in_repo commit -q -am "Main"
  in_repo merge -q side > /dev/null 2>&1

  assert_same "MERGING " "$(in_terminal_zsh "$MARKS")"
}

function test_git_status_marks_a_change_without_running_grep() {
  printf 'new\n' > "$REPO/new.txt"

  assert_same "UNTRACKED " "$(in_terminal_zsh "function grep { print GREP_CALLED; }; $MARKS")"
}

in_repo() {
  git -C "$REPO" -c user.name=Test -c user.email=test@example.com \
    -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}
