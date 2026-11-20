#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
LABEL="$ROOT/herdr-app/mods/tab-bar/label.js"

function set_up() {
  [[ -f $LABEL ]] || bashunit::fail "missing the file under test: $LABEL"
}

function test_a_renamed_tab_shows_its_number_before_its_name() {
  assert_same "3 api" "$(label_of '{"index":1,"name":"api","named":true}' 3)"
}

function test_a_renamed_tab_keeps_its_name_while_a_process_runs_in_it() {
  assert_same "2 api" "$(label_of '{"index":2,"name":"api","named":true}' 2 '{"address":"t7","foreground":{"name":"zsh"}}')"
}

function test_a_tab_nobody_named_shows_its_number_once() {
  assert_same "3" "$(label_of '{"index":1,"name":"1","named":false}' 3)"
}

function test_a_tab_nobody_named_shows_the_process_in_its_terminal() {
  assert_same "2 zsh" "$(label_of '{"index":2,"name":"2","named":false}' 2 '{"address":"t7","foreground":{"name":"zsh"}}')"
}

function test_a_tab_nobody_named_shows_the_process_name_and_not_the_program_name() {
  assert_same "2 nvim" "$(label_of '{"index":2,"name":"2","named":false}' 2 '{"address":"t7","foreground":{"name":"nvim"},"program":{"key":"nvim","name":"Neovim"}}')"
}

function test_a_tab_nobody_named_shows_no_folder() {
  assert_same '""' "$(folder_of '{"index":2,"name":"2","named":false}' '~/prj')"
}

function test_a_renamed_tab_keeps_its_folder() {
  assert_same '"~/prj"' "$(folder_of '{"index":2,"name":"api","named":true}' '~/prj')"
}

# Prints, as JSON, the folder that the tab in $1, a TabInfo as JSON, shows for folder $2.
folder_of() {
  TAB="$1" FOLDER="$2" LABEL="$LABEL" mise x node@latest -- node --input-type=module -e '
    const { tabFolder } = await import(process.env.LABEL);
    console.log(JSON.stringify(tabFolder(JSON.parse(process.env.TAB), process.env.FOLDER)));
  '
}

# Prints the label of the tab in $1, a TabInfo as JSON, that holds number $2.
# $3 is the record of its terminal, as terminals() gives it, when it has one.
label_of() {
  TAB="$1" NUMBER="$2" TERMINAL="${3:-}" LABEL="$LABEL" mise x node@latest -- node --input-type=module -e '
    const { tabLabel } = await import(process.env.LABEL);
    const terminal = process.env.TERMINAL ? JSON.parse(process.env.TERMINAL) : undefined;
    console.log(tabLabel(JSON.parse(process.env.TAB), Number(process.env.NUMBER), terminal));
  '
}
