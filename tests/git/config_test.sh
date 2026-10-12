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

function test_lg_starts_the_author_at_one_column_one_space_after_the_widest_hash() {
  merge_a_side_branch

  local plain
  plain=$(in_clone lg | without_colors)

  assert_same "1" "$(author_columns "$plain" | sort -u | wc -l | tr -d ' ')"
  assert_matches '^\*   [0-9a-f]+ Test Author ' "$(printf '%s\n' "$plain" | head -1)"
}

function test_llg_shows_the_trailers_in_brackets_and_nothing_without_them() {
  merge_a_side_branch

  local plain
  plain=$(in_clone llg | without_colors)

  assert_not_contains "[]" "$plain"
  assert_contains "[fix] Side" "$plain"
}

# HOME is the test folder, so the aliases cannot lean on files installed there.
in_clone() {
  HOME="$WORK" GIT_CONFIG_GLOBAL="$CONFIG" git -C "$WORK/clone" -c user.name="Test Author" \
    -c user.email=test@example.com -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}

# History: Start, a side branch with one commit that has a trailer, a merge.
merge_a_side_branch() {
  in_clone switch -q -c side
  in_clone commit -q --allow-empty -m "Side" -m "Change-type: fix"
  in_clone switch -q -
  in_clone merge -q --no-ff -m "Merge side" side
}

without_colors() {
  sed $'s/\x1b\\[[0-9;]*m//g'
}

# The column where the author starts, for each row that shows a commit.
author_columns() {
  printf '%s\n' "$1" | awk '/[0-9a-f]{7}/ { print index($0, "Test Author") }'
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
