#!/bin/bash

HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/commit-msg"

ASPELL_AVAILABLE=$(command -v aspell > /dev/null 2>&1 && echo "true" || echo "false")

run_hook() {
  local msg_file
  msg_file=$(bashunit::temp_file "commit_msg")
  printf '%s' "$1" > "$msg_file"

  bash "$HOOK" "$msg_file" 2>&1
}

run_hook_without_aspell() {
  local msg_file
  msg_file=$(bashunit::temp_file "commit_msg")
  printf '%s' "$1" > "$msg_file"

  PATH="/usr/bin:/bin" bash "$HOOK" "$msg_file" 2>&1
}

# ------------------------------------------------------------------------------
# Format
# ------------------------------------------------------------------------------

function test_format_accepts_capitalized_imperative_multi_word_title() {
  local output
  output=$(run_hook "Add user search by email")

  assert_successful_code
  assert_equals "" "$output"
}

function test_format_rejects_lowercase_start() {
  local output
  output=$(run_hook "add user search by email")

  assert_general_error
  assert_contains "title format" "$output"
  assert_contains "[FAIL]" "$output"
}

function test_format_rejects_title_ending_with_period() {
  local output
  output=$(run_hook "Add user search by email.")

  assert_general_error
  assert_contains "title format" "$output"
  assert_contains "[FAIL]" "$output"
}

function test_format_rejects_ing_ending_first_word() {
  local output
  output=$(run_hook "Adding user search by email")

  assert_general_error
  assert_contains "title format" "$output"
  assert_contains "[FAIL]" "$output"
}

function test_format_rejects_ed_ending_first_word() {
  local output
  output=$(run_hook "Added user search by email")

  assert_general_error
  assert_contains "title format" "$output"
  assert_contains "[FAIL]" "$output"
}

function test_format_rejects_single_word_title() {
  local output
  output=$(run_hook "Refactor")

  assert_general_error
  assert_contains "title format" "$output"
  assert_contains "[FAIL]" "$output"
}

function test_format_accepts_two_word_title() {
  local output
  output=$(run_hook "Rename method")

  assert_successful_code
  assert_equals "" "$output"
}

function test_format_rejects_empty_title() {
  local output
  output=$(run_hook "")

  assert_general_error
  assert_contains "title format" "$output"
  assert_contains "[FAIL]" "$output"
}

function test_format_accepts_title_with_numbers() {
  local output
  output=$(run_hook "Update version to 5.1 for all servers")

  assert_successful_code
  assert_equals "" "$output"
}

# ------------------------------------------------------------------------------
# Size
# ------------------------------------------------------------------------------

function test_size_accepts_title_at_exactly_72_characters() {
  local title="Upgrade support for the new version of the server and update all clients"
  assert_same "72" "${#title}"

  local output
  output=$(run_hook "$title")

  assert_successful_code
  assert_equals "" "$output"
}

function test_size_rejects_title_at_73_characters() {
  local title="Upgrade support for this new version of the server and update all clients"
  assert_same "73" "${#title}"

  local output
  output=$(run_hook "$title")

  assert_general_error
  assert_contains "size" "$output"
  assert_contains "[FAIL]" "$output"
  assert_contains "73 chars" "$output"
  assert_contains "limit is 72" "$output"
}

# ------------------------------------------------------------------------------
# Spelling
# ------------------------------------------------------------------------------

function test_spelling_rejects_misspelled_word_in_title() {
  if [[ "$ASPELL_AVAILABLE" != "true" ]]; then
    bashunit::skip "aspell not available" && return
  fi

  local output
  output=$(run_hook "Fix the speling of words")

  assert_general_error
  assert_contains "spelling" "$output"
  assert_contains "[FAIL]" "$output"
  assert_contains "speling" "$output"
}

function test_spelling_rejects_misspelled_word_in_body_before_separator() {
  if [[ "$ASPELL_AVAILABLE" != "true" ]]; then
    bashunit::skip "aspell not available" && return
  fi

  local message="Fix the words

This has a speling error
---
Change-type: fix"

  local output
  output=$(run_hook "$message")

  assert_general_error
  assert_contains "spelling" "$output"
  assert_contains "[FAIL]" "$output"
  assert_contains "speling" "$output"
}

function test_spelling_ignores_misspelled_word_in_trailers_after_separator() {
  if [[ "$ASPELL_AVAILABLE" != "true" ]]; then
    bashunit::skip "aspell not available" && return
  fi

  local message="Fix the words

This has no error
---
Change-type: speling"

  local output
  output=$(run_hook "$message")

  assert_successful_code
  assert_equals "" "$output"
}

function test_spelling_shows_not_available_when_aspell_is_missing() {
  local output
  output=$(run_hook_without_aspell "fix the words")

  assert_general_error
  assert_contains "spelling" "$output"
  assert_contains "[NOT AVAILABLE]" "$output"
  assert_contains "Install aspell" "$output"
}

# ------------------------------------------------------------------------------
# Git-generated message bypass
# ------------------------------------------------------------------------------

function test_bypass_accepts_merge_commit_message() {
  local output
  output=$(run_hook "Merge branch 'feature' into main")

  assert_successful_code
  assert_equals "" "$output"
}

function test_bypass_accepts_revert_commit_message() {
  local output
  output=$(run_hook "Revert \"Add user search by email\"")

  assert_successful_code
  assert_equals "" "$output"
}

function test_bypass_accepts_reapply_commit_message() {
  local output
  output=$(run_hook "Reapply \"Add user search by email\"")

  assert_successful_code
  assert_equals "" "$output"
}

function test_bypass_accepts_fixup_commit_message() {
  local output
  output=$(run_hook "fixup! Add user search by email")

  assert_successful_code
  assert_equals "" "$output"
}

function test_bypass_accepts_amend_commit_message() {
  local output
  output=$(run_hook "amend! Add user search by email")

  assert_successful_code
  assert_equals "" "$output"
}
