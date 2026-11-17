#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
KEYMAP="$ROOT/herdr-app/mods/prefix/keymap.js"

function set_up() {
  [[ -f $KEYMAP ]] || bashunit::fail "missing the file under test: $KEYMAP"
}

function test_c_opens_a_new_tab() {
  assert_same '{"run":"tab.new","args":{}}' "$(action_for_key "c")"
}

function test_escape_only_closes_the_popup() {
  assert_same '{"close":true}' "$(action_for_key "escape")"
}

function test_a_second_ctrl_a_sends_a_literal_ctrl_a_to_the_terminal() {
  assert_same '{"send":"ctrl+a"}' "$(action_for_key "a" "control")"
}

function test_a_key_outside_the_table_only_closes_the_popup() {
  assert_same '{"close":true}' "$(action_for_key "q")"
}

function test_a_table_key_with_cmd_held_only_closes_the_popup() {
  assert_same '{"close":true}' "$(action_for_key "c" "platform")"
}

# Prints, as JSON, what the popup does when the key in $1 is pressed after
# the prefix. $2 lists the modifiers held, such as "control", when set.
action_for_key() {
  KEYMAP="$KEYMAP" KEY="$1" MODIFIERS="$2" mise x node@latest -- node --input-type=module -e '
    const { actionFor } = await import(process.env.KEYMAP);
    const held = process.env.MODIFIERS.split(",");
    const modifiers = Object.fromEntries(
      ["shift", "control", "alt", "platform", "function"].map((name) => [name, held.includes(name)]),
    );
    const key = process.env.KEY;
    const event = { key, key_char: modifiers.control || key.length > 1 ? undefined : key, modifiers };
    console.log(JSON.stringify(actionFor(event)));
  '
}
