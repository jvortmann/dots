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

function test_spelling_accepts_british_variant() {
  if [[ "$ASPELL_AVAILABLE" != "true" ]]; then
    bashunit::skip "aspell not available" && return
  fi

  local output
  output=$(run_hook "Organise the modules by behaviour")

  assert_successful_code
  assert_equals "" "$output"
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

See-also: speling"

  local output
  output=$(run_hook "$message")

  assert_successful_code
  assert_equals "" "$output"
}

function test_spelling_ignores_trailers_without_separator() {
  if [[ "$ASPELL_AVAILABLE" != "true" ]]; then
    bashunit::skip "aspell not available" && return
  fi

  local message="Fix the words

This has no error

See-also: speling"

  local output
  output=$(run_hook "$message")

  assert_successful_code
  assert_equals "" "$output"
}

function test_spelling_ignores_git_comment_lines() {
  if [[ "$ASPELL_AVAILABLE" != "true" ]]; then
    bashunit::skip "aspell not available" && return
  fi

  local message="Fix the words

Work-item-id: AUD-2906
Change-type: fix

# Please enter the commit message for your changes.
# On branch main
#
# Changes to be committed:
#	modified: foo.sh
# "

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

# ------------------------------------------------------------------------------
# Combined
# ------------------------------------------------------------------------------

function test_combined_reports_all_failing_checks_at_once() {
  if [[ "$ASPELL_AVAILABLE" != "true" ]]; then
    bashunit::skip "aspell not available" && return
  fi

  local output
  output=$(run_hook "adding the speling of a very long message that is definitely going to exceed the limit.")

  assert_general_error
  assert_contains "- size" "$output"
  assert_contains "- title format" "$output"
  assert_contains "- spelling" "$output"
  assert_contains "87 chars" "$output"
  assert_contains "speling" "$output"
}

function test_combined_shows_pass_for_checks_that_succeed() {
  if [[ "$ASPELL_AVAILABLE" != "true" ]]; then
    bashunit::skip "aspell not available" && return
  fi

  local output
  output=$(run_hook "Fix the speling of words")

  assert_general_error
  assert_contains "- size" "$output"
  assert_contains "- title format" "$output"
  assert_contains "- spelling" "$output"

  # size and format pass, only spelling fails
  assert_matches "size.*\[PASS\]" "$output"
  assert_matches "title format.*\[PASS\]" "$output"
  assert_matches "spelling.*\[FAIL\]" "$output"
}

# ------------------------------------------------------------------------------
# Trailers
# ------------------------------------------------------------------------------

function test_trailers_accepts_valid_change_type() {
  local message="Fix the words

Change-type: fix"

  local output
  output=$(run_hook "$message")

  assert_successful_code
  assert_equals "" "$output"
}

function test_trailers_rejects_invalid_change_type() {
  local message="Fix the words

Change-type: invalid"

  local output
  output=$(run_hook "$message")

  assert_general_error
  assert_contains "change-type" "$output"
  assert_contains "[FAIL]" "$output"
  assert_contains "invalid" "$output"
}

function test_trailers_report_invalid_change_type_without_a_shell_error() {
  local message="Fix the words

Change-type: invalid"

  local output
  output=$(run_hook "$message")

  assert_general_error
  assert_not_contains "can only be used in a function" "$output"
}

function test_trailers_rejects_a_leftover_change_type_placeholder() {
  local message="Fix the words

Change-type: fix
Change-type: feature|refactor|fix|docs|style|test|ci|deps|config|chore"

  local output
  output=$(run_hook "$message")

  assert_general_error
  assert_contains "change-type" "$output"
  assert_contains "[FAIL]" "$output"
}

function test_trailers_rejects_two_valid_change_types() {
  local message="Fix the words

Change-type: fix
Change-type: feature"

  local output
  output=$(run_hook "$message")

  assert_general_error
  assert_contains "change-type" "$output"
  assert_contains "one Change-type" "$output"
}

function test_trailers_rejects_an_agent_co_author() {
  local message="Fix the words

Co-authored-by: Claude <noreply@anthropic.com>
Change-type: fix"

  local output
  output=$(run_hook "$message")

  assert_general_error
  assert_contains "agent trailer" "$output"
  assert_contains "[FAIL]" "$output"
}

function test_trailers_rejects_a_generated_with_trailer() {
  local message="Fix the words

Generated with: Claude Code
Change-type: fix"

  local output
  output=$(run_hook "$message")

  assert_general_error
  assert_contains "agent trailer" "$output"
}

function test_trailers_accepts_a_human_co_author() {
  local message="Fix the words

Co-authored-by: Ada Lovelace <ada@example.com>
Change-type: fix"

  local output
  output=$(run_hook "$message")

  assert_successful_code
  assert_equals "" "$output"
}

function test_trailers_accepts_message_without_change_type() {
  local message="Fix the words

Work-item-id: AUD-1234"

  local output
  output=$(run_hook "$message")

  assert_successful_code
  assert_equals "" "$output"
}

function test_trailers_accepts_see_also_references() {
  local message="Adapt the investigate skill

The order of the work comes from an outside source.

Change-type: feature
See-also: https://github.com/juanibiapina/dotfiles
See-also: 6ed2658fb9c4a9e93e3216f32071c030f14d7d28
See-also: git/hooks/commit-msg:111"

  local output
  output=$(run_hook "$message")

  assert_successful_code
  assert_equals "" "$output"
}

function test_trailers_accepts_several_advisory_ids() {
  local message="Bump the parser to the patched version

The old range carries two advisories, and only one has both ids.

Work-item-id: AUD-3410
Change-type: deps
GHSA-id: GHSA-rgxp-2hwp-jwgg
CVE-id: CVE-2026-25087
GHSA-id: GHSA-6v7p-g79w-8964"

  local output
  output=$(run_hook "$message")

  assert_successful_code
  assert_equals "" "$output"
}

function test_trailers_accepts_message_without_any_trailers() {
  local output
  output=$(run_hook "Fix the words")

  assert_successful_code
  assert_equals "" "$output"
}
