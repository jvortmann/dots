#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIG="$ROOT/git/config"

function set_up() {
  [[ -f $CONFIG ]] || bashunit::fail "missing the file under test: $CONFIG"
  WORK=$(bashunit::temp_dir "bdg")
  git init -q --bare "$WORK/remote.git"
  git clone -q "$WORK/remote.git" "$WORK/clone" 2> /dev/null
  in_clone commit -q --allow-empty -m "Start"
  in_clone push -q -u origin HEAD 2> /dev/null
}

function test_bdg_deletes_a_gone_branch_when_the_current_one_is_gone_too() {
  push_branch current
  push_branch merged
  in_clone switch -q current
  delete_upstream current merged

  local output
  output=$(in_clone bdg 2>&1)

  assert_not_contains "error" "$output"
  assert_same "current" "$(branches_like 'current\|merged')"
}

function test_bdg_keeps_a_gone_branch_that_a_worktree_uses() {
  push_branch elsewhere
  push_branch merged
  in_clone worktree add -q "$WORK/elsewhere" elsewhere
  delete_upstream elsewhere merged

  local output
  output=$(in_clone bdg 2>&1)

  assert_not_contains "error" "$output"
  assert_same "elsewhere" "$(branches_like 'elsewhere\|merged')"
}

function test_bdg_does_nothing_when_no_branch_is_gone() {
  push_branch active

  local output
  output=$(in_clone bdg 2>&1)

  assert_same "" "$output"
  assert_same "active" "$(branches_like 'active')"
}

function test_bdg_lists_only_the_names_to_delete() {
  push_branch active
  push_branch merged
  delete_upstream merged

  local listing
  listing=$(in_clone config alias.bdg | sed -e 's/^!git //' -e 's/ | xargs.*//')

  assert_same "merged" "$(eval "in_clone $listing")"
}

in_clone() {
  GIT_CONFIG_GLOBAL="$CONFIG" git -C "$WORK/clone" \
    -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}

push_branch() {
  in_clone branch -q "$1"
  in_clone push -q -u origin "$1" 2> /dev/null
}

delete_upstream() {
  git -C "$WORK/remote.git" branch -q -D "$@"
  in_clone fetch -q --prune
}

branches_like() {
  in_clone for-each-ref --format='%(refname:short)' refs/heads | command grep "^\($1\)$" | paste -sd' ' -
}
