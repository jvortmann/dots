#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
NUMBERS="$ROOT/herdr-app/mods/tab-bar/numbers.js"
SHOTS="$ROOT/tests/herdr-app/mods/tab-bar/shots.js"

function set_up() {
  [[ -f $NUMBERS ]] || bashunit::fail "missing the file under test: $NUMBERS"
}

function test_tabs_seen_first_take_their_position_as_their_number() {
  assert_same "t1=1 t2=2 t3=3" "$(numbers_after "*s1:*t1,t2,t3")"
}

function test_a_tab_keeps_its_number_when_a_tab_before_it_closes() {
  assert_same "t1=1 t3=3" "$(numbers_after "*s1:*t1,t2,t3" "*s1:*t1,t3")"
}

function test_a_new_tab_takes_the_lowest_free_number() {
  assert_same "t1=1 t3=3 t4=2" "$(numbers_after "*s1:*t1,t2,t3" "*s1:*t1,t3" "*s1:t1,t3,*t4")"
}

function test_with_no_free_number_a_new_tab_takes_the_next_one() {
  assert_same "t1=1 t3=3 t4=2 t5=4" "$(numbers_after "*s1:*t1,t2,t3" "*s1:*t1,t3" "*s1:t1,t3,*t4" "*s1:t1,t3,t4,*t5")"
}

function test_a_space_out_of_sight_while_the_layout_loads_keeps_its_numbers() {
  assert_same "t1=1 t3=3" "$(numbers_after "*s1:*t1,t2,t3" "*s1:*t1,t3" "" "*s1:*t1,t3")"
}

function test_a_new_tab_moves_between_the_tabs_with_the_numbers_around_its_own() {
  assert_same "t4 2" "$(move_after "*s1:*t1,t2,t3" "*s1:*t1,t3" "*s1:t1,t3,*t4")"
}

function test_tabs_in_number_order_stay_where_they_are() {
  assert_same "null" "$(move_after "*s1:*t1,t2,t3" "*s1:*t1,t3")"
}

function test_swapping_left_trades_numbers_with_the_tab_before() {
  assert_same "t1=3 t3=1" "$(numbers_after_swap -1 "*s1:*t1,t2,t3" "*s1:t1,*t3")"
}

function test_swapping_left_from_the_first_tab_trades_numbers_with_the_last_tab() {
  assert_same "t1=3 t2=2 t3=1" "$(numbers_after_swap -1 "*s1:*t1,t2,t3")"
}

function test_swapping_right_from_the_last_tab_trades_numbers_with_the_first_tab() {
  assert_same "t1=3 t2=2 t3=1" "$(numbers_after_swap 1 "*s1:t1,t2,*t3")"
}

function test_a_number_selects_the_tab_that_holds_it_and_not_the_tab_at_that_place() {
  assert_same "t3" "$(tab_numbered 3 "*s1:*t1,t2,t3" "*s1:*t1,t3")"
}

function test_a_number_no_tab_holds_selects_nothing() {
  assert_same "null" "$(tab_numbered 2 "*s1:*t1,t2,t3" "*s1:*t1,t3")"
}

# Shows each argument to the numbers in turn, and prints the number of each
# tab of the shown space after the last one, in its order. An argument lists
# the spaces, as in "*s1:t1,*t2 s2:*u1": a star marks the shown space, and the
# tab that a space shows. An empty argument shows no space.
numbers_after() {
  run_numbers numbers "$@"
}

# Shows each argument to the numbers, as numbers_after does, and prints the
# tab that must move to put the shown space in number order, and the place it
# moves to, or null.
move_after() {
  run_numbers move "$@"
}

# Shows each argument to the numbers, as numbers_after does, swaps the shown
# tab with the tab $1 places away, and prints the numbers as numbers_after does.
numbers_after_swap() {
  SWAP="$1" run_numbers numbers "${@:2}"
}

# Shows each argument to the numbers, as numbers_after does, and prints the
# tab of the shown space that holds number $1, or null.
tab_numbered() {
  NUMBER="$1" run_numbers tab "${@:2}"
}

run_numbers() {
  PRINT="$1" NUMBERS="$NUMBERS" SHOTS="$SHOTS" mise x node@latest -- node --input-type=module -e '
    const { numberTabs, nextMove, swapNumbers, tabNumbered } = await import(process.env.NUMBERS);
    const { parseShot } = await import(process.env.SHOTS);
    const shots = process.argv.slice(1).map(parseShot);
    const seen = shots.reduce((seen, shot) => numberTabs(seen, shot), {});
    const space = shots.at(-1).find((s) => s.active);
    const record = process.env.SWAP ? swapNumbers(seen, space, Number(process.env.SWAP)) : seen;
    if (process.env.PRINT === "tab") console.log(String(tabNumbered(record, space, Number(process.env.NUMBER))));
    else if (process.env.PRINT === "move") {
      const move = nextMove(record, space);
      console.log(move ? `${move.id} ${move.index}` : "null");
    } else console.log(space.tabs.map((t) => `${t.id}=${record[space.id]?.[t.id]}`).join(" "));
  ' "${@:2}"
}
