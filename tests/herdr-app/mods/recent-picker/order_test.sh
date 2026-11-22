#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
ORDER="$ROOT/herdr-app/mods/recent-picker/order.js"
SHOTS="$ROOT/tests/herdr-app/mods/shots.js"

function set_up() {
  [[ -f $ORDER ]] || bashunit::fail "missing the file under test: $ORDER"
}

function test_the_spaces_go_from_the_shown_space_to_the_space_shown_longest_ago() {
  assert_same "s3 s4 s1 s2" "$(spaces_in_order "s3 s4 s1 s2" "s1:*t1 s2:*u1 *s3:*v1 s4:*w1")"
}

function test_the_spaces_never_shown_come_last_in_the_order_of_the_sidebar() {
  assert_same "s3 s1 s2 s4" "$(spaces_in_order "s3" "s1:*t1 s2:*u1 *s3:*v1 s4:*w1")"
}

function test_a_closed_space_in_the_record_does_not_show() {
  assert_same "s3 s1" "$(spaces_in_order "s3 s2 s1" "s1:*t1 *s3:*v1")"
}

function test_the_shown_space_comes_first_when_the_record_does_not_name_it_yet() {
  assert_same "s2 s1" "$(spaces_in_order "" "s1:*t1 *s2:*u1")"
}

function test_the_picker_opens_on_the_tab_that_the_previous_space_showed_last() {
  assert_same "t2" "$(tab_chosen_on_open "s2 s1" "s1:t1,*t2 *s2:*u1")"
}

function test_with_one_space_the_picker_opens_on_the_shown_tab() {
  assert_same "t2" "$(tab_chosen_on_open "s1" "*s1:t1,*t2")"
}

# Lists the spaces in the order the picker shows them: the record of the
# tab bar is the first argument, and the spaces are the second, as shots.js
# reads them.
spaces_in_order() {
  pick order "$@"
}

# Prints the tab that the picker chooses when it opens, from the same
# arguments as spaces_in_order.
tab_chosen_on_open() {
  pick open "$@"
}

pick() {
  PRINT="$1" ORDER="$ORDER" SHOTS="$SHOTS" mise x node@latest -- node --input-type=module -e '
    const { recentSpaces, openingTab } = await import(process.env.ORDER);
    const { parseShot } = await import(process.env.SHOTS);
    const [record, shot] = process.argv.slice(1);
    const history = record.split(" ").filter(Boolean);
    const spaces = parseShot(shot);
    if (process.env.PRINT === "open") console.log(String(openingTab(spaces, history)));
    else console.log(recentSpaces(spaces, history).map((s) => s.id).join(" "));
  ' "${@:2}"
}
