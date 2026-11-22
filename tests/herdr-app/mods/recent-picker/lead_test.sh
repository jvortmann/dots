#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
PICKER="$ROOT/herdr-app/mods/recent-picker/lead.js"
BAR="$ROOT/herdr-app/mods/tab-bar/lead.js"

function set_up() {
  [[ -f $PICKER ]] || bashunit::fail "missing the file under test: $PICKER"
}

function test_a_zsh_tab_shows_the_shell_icon_in_the_picker_as_in_the_tab_bar() {
  assert_same "shell null|shell null" "$(icons_of '[{"tab":"t1","focused":true,"program":{"key":"shell"}}]')"
}

function test_an_nvim_tab_shows_the_nvim_icon_in_the_picker_as_in_the_tab_bar() {
  assert_same "nvim null|nvim null" "$(icons_of '[{"tab":"t1","program":{"key":"shell"}},{"tab":"t1","focused":true,"program":{"key":"nvim"}}]')"
}

function test_a_pi_tab_shows_the_pi_icon_and_its_dot_in_the_picker_as_in_the_tab_bar() {
  assert_same "pi working|pi working" "$(icons_of '[{"tab":"t1","status":"working","program":{"key":"pi","agent":true}}]')"
}

function test_a_focused_zsh_beside_pi_shows_zsh_with_no_dot_in_the_picker_as_in_the_tab_bar() {
  assert_same "shell null|shell null" "$(icons_of '[{"tab":"t1","status":"working","program":{"key":"pi","agent":true}},{"tab":"t1","focused":true,"program":{"key":"shell"}}]')"
}

# Prints the program key and the status of the pane that leads tab t1, from
# the panes in $1 as JSON: first as the picker chooses, then as the tab bar does.
icons_of() {
  PICKER="$PICKER" BAR="$BAR" mise x node@latest -- node --input-type=module -e '
    const panes = JSON.parse(process.argv[1]);
    const shown = async (file) => {
      const p = (await import(file)).lead(panes, "t1");
      return `${p?.program.key} ${p?.status ?? null}`;
    };
    console.log(`${await shown(process.env.PICKER)}|${await shown(process.env.BAR)}`);
  ' "$1"
}
