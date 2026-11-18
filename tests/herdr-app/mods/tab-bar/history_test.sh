#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
HISTORY="$ROOT/herdr-app/mods/tab-bar/history.js"

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

observe() {
  PRINT="$1" HISTORY="$HISTORY" mise x node@latest -- node --input-type=module -e '
    const { observeTabs, lastTab } = await import(process.env.HISTORY);
    const item = (name) => ({ id: name.replace("*", ""), active: name.startsWith("*") });
    const shots = process.argv.slice(1).map((shot) => shot.split(" ").map((space) => {
      const [name, tabs] = space.split(":");
      return { ...item(name), tabs: tabs.split(",").filter(Boolean).map(item) };
    }));
    const history = shots.reduce((seen, shot) => observeTabs(seen, shot), {});
    if (process.env.PRINT === "spaces") console.log(Object.keys(history).join(" "));
    else console.log(String(lastTab(history, shots.at(-1))));
  ' "${@:2}"
}
