#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
LABEL="$ROOT/herdr-app/mods/tab-bar/label.js"

function set_up() {
  [[ -f $LABEL ]] || bashunit::fail "missing the file under test: $LABEL"
}

function test_a_renamed_tab_shows_its_number_before_its_name() {
  assert_same "3 api" "$(label_of '{"index":1,"name":"api","named":true}' 3)"
}

function test_a_tab_nobody_named_shows_its_number_once() {
  assert_same "3" "$(label_of '{"index":1,"name":"1","named":false}' 3)"
}

# Prints the label of the tab in $1, a TabInfo as JSON, that holds number $2.
label_of() {
  TAB="$1" NUMBER="$2" LABEL="$LABEL" mise x node@latest -- node --input-type=module -e '
    const { tabLabel } = await import(process.env.LABEL);
    console.log(tabLabel(JSON.parse(process.env.TAB), Number(process.env.NUMBER)));
  '
}
