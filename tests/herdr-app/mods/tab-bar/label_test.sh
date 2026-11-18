#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
LABEL="$ROOT/herdr-app/mods/tab-bar/label.js"

function set_up() {
  [[ -f $LABEL ]] || bashunit::fail "missing the file under test: $LABEL"
}

function test_a_renamed_tab_shows_its_position_before_its_name() {
  assert_same "2 api" "$(label_of '{"index":2,"name":"api","named":true}')"
}

function test_a_tab_nobody_named_shows_its_position_once() {
  assert_same "2" "$(label_of '{"index":2,"name":"2","named":false}')"
}

# Prints the label of the tab in $1, a TabInfo as JSON.
label_of() {
  TAB="$1" LABEL="$LABEL" mise x node@latest -- node --input-type=module -e '
    const { tabLabel } = await import(process.env.LABEL);
    console.log(tabLabel(JSON.parse(process.env.TAB)));
  '
}
