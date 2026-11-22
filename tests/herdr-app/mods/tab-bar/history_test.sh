#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
HISTORY="$ROOT/herdr-app/mods/tab-bar/history.js"
SHOTS="$ROOT/tests/herdr-app/mods/shots.js"

function set_up() {
  [[ -f $HISTORY ]] || bashunit::fail "missing the file under test: $HISTORY"
}

function test_after_a_switch_the_last_tab_is_the_tab_shown_before() {
  assert_same "t1" "$(last_tab_after "*s1:*t1,t2" "*s1:t1,*t2")"
}

function test_going_back_to_the_last_tab_makes_the_tab_left_the_last_tab() {
  assert_same "t2" "$(last_tab_after "*s1:*t1,t2" "*s1:t1,*t2" "*s1:*t1,t2")"
}

function test_each_space_keeps_its_own_last_tab() {
  assert_same "t1" "$(last_tab_after \
    "*s1:*t1,t2 s2:*u1,u2" \
    "*s1:t1,*t2 s2:*u1,u2" \
    "s1:t1,*t2 *s2:*u1,u2" \
    "s1:t1,*t2 *s2:u1,*u2" \
    "*s1:t1,*t2 s2:u1,*u2")"
}

function test_a_closed_tab_is_no_longer_the_last_tab() {
  assert_same "null" "$(last_tab_after "*s1:*t1,t2" "*s1:t1,*t2" "*s1:*t1")"
}

function test_the_record_forgets_a_closed_space() {
  assert_same "s1" "$(spaces_in_record_after "*s1:*t1 s2:*u1" "s1:*t1 *s2:*u1" "*s1:*t1")"
}

function test_the_spaces_go_from_the_shown_space_to_the_space_shown_longest_ago() {
  assert_same "s2 s3 s1" "$(spaces_by_recency_after "*s1:*t1 s2:*u1 s3:*v1" "s1:*t1 s2:*u1 *s3:*v1" "s1:*t1 *s2:*u1 s3:*v1")"
}

function test_the_space_history_forgets_a_closed_space() {
  assert_same "s1" "$(spaces_by_recency_after "*s1:*t1 s2:*u1" "s1:*t1 *s2:*u1" "*s1:*t1")"
}

# Shows each argument to the history in turn, and prints the last tab of the
# shown space after the last one, or null. An argument lists the spaces, as in
# "*s1:t1,*t2 s2:*u1": a star marks the shown space, and the tab that a space shows.
last_tab_after() {
  observe last-tab "$@"
}

# Shows each argument to the history in turn, as last_tab_after does, and
# prints the spaces that the record keeps.
spaces_in_record_after() {
  observe spaces "$@"
}

# Shows each argument to the space history in turn, and prints its spaces.
spaces_by_recency_after() {
  observe recency "$@"
}

observe() {
  PRINT="$1" HISTORY="$HISTORY" SHOTS="$SHOTS" mise x node@latest -- node --input-type=module -e '
    const { observeTabs, observeSpaces, lastTab } = await import(process.env.HISTORY);
    const { parseShot } = await import(process.env.SHOTS);
    const shots = process.argv.slice(1).map(parseShot);
    const history = shots.reduce((seen, shot) => observeTabs(seen, shot), {});
    if (process.env.PRINT === "recency") console.log(shots.reduce((seen, shot) => observeSpaces(seen, shot), []).join(" "));
    else if (process.env.PRINT === "spaces") console.log(Object.keys(history).join(" "));
    else console.log(String(lastTab(history, shots.at(-1))));
  ' "${@:2}"
}
