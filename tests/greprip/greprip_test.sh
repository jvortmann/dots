#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GREPRIP="$ROOT/greprip/greprip.sh"

# Run a command in bash, from a git repository with one ignored file, after
# sourcing the greprip functions as an agent shell does. The ripgrep config of
# whoever runs the tests stays out, unless a test sets RG_CONFIG.
in_repository() {
  (cd "$REPO" && RIPGREP_CONFIG_PATH="${RG_CONFIG:-}" bash -c "source '$GREPRIP'; $1" 2>&1)
}

function set_up() {
  [[ -f $GREPRIP ]] || bashunit::fail "missing the file under test: $GREPRIP"
  command -v grg > /dev/null && command -v fnd > /dev/null || bashunit::skip "needs grg and fnd"
  REPO=$(bashunit::temp_dir "greprip")
  git -C "$REPO" init -q
  mkdir -p "$REPO/src" "$REPO/build"
  printf 'Alpha foo\nbeta Foo\ngamma\n' > "$REPO/src/one.ts"
  printf 'foo\n' > "$REPO/build/out.ts"
  printf 'build/\n' > "$REPO/.gitignore"
}

function test_a_recursive_grep_skips_ignored_files() {
  assert_same "./src/one.ts:1:Alpha foo" "$(in_repository 'grep -rn foo .')"
}

function test_grep_stays_case_sensitive_under_a_smart_case_ripgrep_config() {
  RG_CONFIG=$(bashunit::temp_file "rgrc")
  printf -- '--smart-case\n' > "$RG_CONFIG"

  assert_same "Alpha foo" "$(in_repository 'grep foo src/one.ts')"
}

function test_grep_with_an_attached_context_count_prints_the_context() {
  assert_same "Alpha foo
beta Foo" "$(in_repository 'grep -A1 Alpha src/one.ts')"
}

function test_find_by_name_skips_ignored_files() {
  assert_same "./src/one.ts" "$(in_repository "find . -name '*.ts'")"
}

function test_find_newer_lists_only_the_files_changed_after_the_reference() {
  touch -t 202001010000 "$REPO/src/old.ts"
  touch -t 202101010000 "$REPO/reference"

  assert_same "src/one.ts" "$(in_repository 'find src -type f -newer reference')"
}

function test_grep_and_find_work_as_before_when_greprip_is_missing() {
  local output
  output=$(cd "$REPO" && PATH=/usr/bin:/bin bash -c "source '$GREPRIP'; grep -rln foo . | sort; find . -name out.ts" 2>&1)

  assert_same "./build/out.ts
./src/one.ts
./build/out.ts" "$output"
}

function test_grep_reads_a_question_mark_as_a_literal_character() {
  assert_same "" "$(in_repository "printf 'no marks here\n' | grep '^??'")"
}

function test_grep_reads_a_plus_sign_as_a_literal_character() {
  assert_same "" "$(in_repository "printf 'aaa\n' | grep 'a+'")"
}

function test_grep_reads_a_bar_as_a_literal_character() {
  assert_same "" "$(in_repository "printf 'a\n' | grep 'a|b'")"
}

function test_grep_reads_a_brace_as_a_literal_character() {
  assert_same "" "$(in_repository "printf 'xx\n' | grep 'x{2}'")"
}

function test_an_extended_recursive_grep_still_skips_ignored_files() {
  assert_same "./src/one.ts:1:Alpha foo" "$(in_repository "grep -rn -E 'fo+' .")"
}
