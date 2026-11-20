#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
LABEL="$ROOT/herdr-app/mods/tab-bar/label.js"

function set_up() {
  [[ -f $LABEL ]] || bashunit::fail "missing the file under test: $LABEL"
}

function test_a_renamed_tab_shows_its_name() {
  assert_same '"api"' "$(text_of '{"index":2,"name":"api","named":true}')"
}

function test_a_tab_nobody_named_shows_the_process_in_its_terminal() {
  assert_same '"zsh"' "$(text_of '{"index":2,"name":"2","named":false}' '{"address":"t7","foreground":{"name":"zsh"}}')"
}

function test_a_renamed_tab_keeps_its_name_while_a_process_runs_in_it() {
  assert_same '"api"' "$(text_of '{"index":2,"name":"api","named":true}' '{"address":"t7","foreground":{"name":"zsh"}}')"
}

function test_a_tab_nobody_named_with_no_process_shows_no_text() {
  assert_same '""' "$(text_of '{"index":2,"name":"2","named":false}')"
}

function test_a_tab_nobody_named_shows_the_process_name_and_not_the_program_name() {
  assert_same '"nvim"' "$(text_of '{"index":2,"name":"2","named":false}' '{"address":"t7","foreground":{"name":"nvim"},"program":{"key":"nvim","name":"Neovim"}}')"
}

# Prints, as JSON, the text that the tab in $1, a TabInfo as JSON, shows after its icon.
# $2 is the record of its terminal, as terminals() gives it, when it has one.
text_of() {
  TAB="$1" TERMINAL="${2:-}" LABEL="$LABEL" mise x node@latest -- node --input-type=module -e '
    const { tabText } = await import(process.env.LABEL);
    const terminal = process.env.TERMINAL ? JSON.parse(process.env.TERMINAL) : undefined;
    console.log(JSON.stringify(tabText(JSON.parse(process.env.TAB), terminal)));
  '
}
