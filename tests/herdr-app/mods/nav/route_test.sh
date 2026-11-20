#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
ROUTE="$ROOT/herdr-app/mods/nav/route.js"

function set_up() {
  [[ -f $ROUTE ]] || bashunit::fail "missing the file under test: $ROUTE"
}

function test_a_key_in_a_shell_goes_to_the_pane_in_its_direction() {
  assert_same '{"go":"down"}' "$(route_of down "$(focus)" "$(panes_with shell)")"
}

function test_a_key_in_nvim_goes_on_to_nvim_so_that_it_moves_between_its_own_windows() {
  assert_same '{"terminal":"t7","keys":"ctrl+j"}' "$(route_of down "$(focus)" "$(panes_with nvim)")"
}

function test_a_key_in_pi_goes_to_the_pane_in_its_direction() {
  assert_same '{"go":"right"}' "$(route_of right "$(focus)" "$(panes_with pi)")"
}

function test_a_key_in_copy_mode_goes_to_the_pane_in_its_direction_though_copy_mode_runs_nvim() {
  assert_same '{"go":"up"}' "$(route_of up "$(focus '"t9"')" "$(panes_with nvim)")"
}

function test_a_key_does_nothing_while_nothing_has_the_focus() {
  assert_same "null" "$(route_of left null "$(panes_with shell)")"
}

function test_a_key_does_nothing_while_a_terminal_outside_the_panes_has_the_focus() {
  assert_same "null" "$(route_of left '{"pane":null,"terminal":"t5","shown":null}' "$(panes_with shell)")"
}

function test_a_key_goes_to_the_pane_in_its_direction_while_the_panes_do_not_list_the_focused_one_yet() {
  assert_same '{"go":"left"}' "$(route_of left "$(focus)" '[{"pane":"p2","terminal":"t8","program":{"key":"shell"}}]')"
}

function test_a_command_that_names_no_direction_does_nothing() {
  assert_same "null" "$(route_of focus "$(focus)" "$(panes_with shell)")"
}

# Prints, as JSON, what the nav mod does with the command $1 while the
# focus is $2, the JSON of focused(), over the panes $3, the JSON of panes().
route_of() {
  COMMAND="$1" FOCUSED="$2" PANES="$3" ROUTE="$ROUTE" mise x node@latest -- node --input-type=module -e '
    const { route } = await import(process.env.ROUTE);
    const { COMMAND, FOCUSED, PANES } = process.env;
    console.log(JSON.stringify(route(COMMAND, JSON.parse(FOCUSED), JSON.parse(PANES))));
  '
}

# Prints focused() on pane p1 with terminal t7, and the terminal $1 shown
# over it when set.
focus() {
  printf '{"space":"s1","tab":"w1","pane":"p1","terminal":"t7","shown":%s}' "${1:-null}"
}

# Prints panes(): pane p2 with a shell, and the focused pane p1 with
# terminal t7, which runs the program $1.
panes_with() {
  printf '[{"pane":"p2","terminal":"t8","program":{"key":"shell"},"focused":false},'
  printf '{"pane":"p1","terminal":"t7","program":{"key":"%s"},"focused":true}]' "$1"
}
