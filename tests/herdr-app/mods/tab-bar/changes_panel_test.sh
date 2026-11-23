#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
PANEL="$ROOT/herdr-app/mods/tab-bar/changes-panel.js"

function set_up() {
  [[ -f $PANEL ]] || bashunit::fail "missing the file under test: $PANEL"
}

function test_a_click_while_the_panel_is_hidden_shows_the_changes_in_it() {
  assert_same '[["layout.select",{"stack":"panel-body","child":"changes"}],["layout.show",{"id":"panel"}]]' \
    "$(clicked "$(layout_with true changes)")"
}

function test_a_click_while_the_panel_shows_the_changes_hides_it() {
  assert_same '[["layout.hide",{"id":"panel"}]]' "$(clicked "$(layout_with false changes)")"
}

function test_a_click_while_the_panel_shows_another_view_shows_the_changes_in_it() {
  assert_same '[["layout.select",{"stack":"panel-body","child":"changes"}],["layout.show",{"id":"panel"}]]' \
    "$(clicked "$(layout_with false files)")"
}

# Prints a layout whose panel is hidden ($1) and whose stack shows the child $2.
layout_with() {
  printf '{"id":"root","children":[{"id":"main"},{"id":"panel","hidden":%s,"children":[{"id":"panel-body","active":"%s"}]}]}' "$1" "$2"
}

# Prints the commands that a click on the Changes button runs in the layout $1.
clicked() {
  PANEL="$PANEL" mise x node@latest -- node --input-type=module -e '
    const { toggleChanges } = await import(process.env.PANEL);
    console.log(JSON.stringify(toggleChanges(JSON.parse(process.argv[1]))));
  ' "$1" 2>&1
}
