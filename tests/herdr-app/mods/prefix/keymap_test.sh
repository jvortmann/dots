#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
KEYMAP="$ROOT/herdr-app/mods/prefix/keymap.js"

function set_up() {
  [[ -f $KEYMAP ]] || bashunit::fail "missing the file under test: $KEYMAP"
}

function test_c_opens_a_new_tab() {
  assert_same '{"run":"tab.new","args":{}}' "$(action_for_key "c")"
}

function test_ctrl_c_opens_a_new_tab() {
  assert_same '{"run":"tab.new","args":{}}' "$(action_for_key "c" "control")"
}

function test_v_bar_and_backslash_split_the_pane_to_the_right() {
  local split_right='{"run":"pane.split","args":{"direction":"right"}}'
  assert_same "$split_right" "$(action_for_key "v")"
  assert_same "$split_right" "$(action_for_key "|")"
  assert_same "$split_right" "$(action_for_key "\\")"
}

function test_s_dash_and_underscore_split_the_pane_down() {
  local split_down='{"run":"pane.split","args":{"direction":"down"}}'
  assert_same "$split_down" "$(action_for_key "s")"
  assert_same "$split_down" "$(action_for_key "-")"
  assert_same "$split_down" "$(action_for_key "_")"
}

function test_capital_a_and_comma_rename_the_tab() {
  local rename='{"run":"tab.rename","args":{}}'
  assert_same "$rename" "$(action_for_key "A" "shift")"
  assert_same "$rename" "$(action_for_key ",")"
}

function test_h_j_k_l_go_to_the_pane_left_down_up_and_right() {
  assert_same '{"run":"pane.go","args":{"direction":"left"}}' "$(action_for_key "h")"
  assert_same '{"run":"pane.go","args":{"direction":"down"}}' "$(action_for_key "j")"
  assert_same '{"run":"pane.go","args":{"direction":"up"}}' "$(action_for_key "k")"
  assert_same '{"run":"pane.go","args":{"direction":"right"}}' "$(action_for_key "l")"
}

function test_ctrl_h_and_ctrl_j_go_to_the_pane_left_and_down() {
  assert_same '{"run":"pane.go","args":{"direction":"left"}}' "$(action_for_key "h" "control")"
  assert_same '{"run":"pane.go","args":{"direction":"down"}}' "$(action_for_key "j" "control")"
}

function test_z_zooms_the_pane() {
  assert_same '{"run":"pane.zoom","args":{}}' "$(action_for_key "z")"
}

function test_x_closes_the_pane() {
  assert_same '{"run":"pane.close","args":{}}' "$(action_for_key "x")"
}

function test_ampersand_closes_the_tab() {
  assert_same '{"run":"tab.close","args":{}}' "$(action_for_key "&")"
}

function test_n_and_p_go_to_the_next_and_previous_tab() {
  assert_same '{"run":"tab.next","args":{}}' "$(action_for_key "n")"
  assert_same '{"run":"tab.prev","args":{}}' "$(action_for_key "p")"
}

function test_less_than_and_greater_than_move_the_tab_left_and_right() {
  assert_same '{"run":"tab.move","args":{"by":-1}}' "$(action_for_key "<" "shift")"
  assert_same '{"run":"tab.move","args":{"by":1}}' "$(action_for_key ">" "shift")"
}

function test_digits_1_to_9_select_the_tab_at_that_position() {
  assert_same '{"run":"tab.select","args":{"index":1}}' "$(action_for_key "1")"
  assert_same '{"run":"tab.select","args":{"index":5}}' "$(action_for_key "5")"
  assert_same '{"run":"tab.select","args":{"index":9}}' "$(action_for_key "9")"
}

function test_ctrl_f_opens_the_picker_of_tabs_and_spaces() {
  assert_same '{"run":"mod.open","args":{"name":"picker"}}' "$(action_for_key "f" "control")"
}

function test_ctrl_a_selects_the_last_tab() {
  assert_same '{"run":"tab.select","args":{"id":"t2"}}' "$(action_for_key "a" "control" "t2")"
}

function test_ctrl_a_with_no_last_tab_only_closes_the_popup() {
  assert_same '{"close":true}' "$(action_for_key "a" "control")"
}

function test_the_prefix_in_another_tab_makes_the_tab_before_it_the_last_tab() {
  assert_same "t1" "$(last_tab_after_opens "s1:t1 s1:t2")"
}

function test_the_prefix_twice_in_one_tab_keeps_the_last_tab() {
  assert_same "t1" "$(last_tab_after_opens "s1:t1 s1:t2 s1:t2")"
}

function test_each_space_keeps_its_own_last_tab() {
  assert_same "t1" "$(last_tab_after_opens "s1:t1 s1:t2 s2:t8 s2:t9 s1:t2")"
}

function test_a_closed_last_tab_is_no_last_tab() {
  assert_same "" "$(last_tab_after_opens "s1:t1 s1:t2" "t2")"
}

function test_the_popup_spells_a_ctrl_key_with_a_caret() {
  assert_same "c ^c" "$(popup_keys_for "New tab")"
}

function test_the_popup_shows_the_tab_digits_as_one_range() {
  assert_same "1-9" "$(popup_keys_for "Select tab")"
}

function test_the_popup_groups_the_keys_under_tabs_panes_and_other() {
  assert_same "Tabs Panes Other" "$(popup_groups)"
}

function test_the_history_forgets_a_closed_space() {
  assert_same "s2" "$(spaces_in_history_after_opens "s1:t1 s2:t2" "s2")"
}

function test_escape_only_closes_the_popup() {
  assert_same '{"close":true}' "$(action_for_key "escape")"
}

function test_a_sends_a_literal_ctrl_a_to_the_terminal() {
  assert_same '{"send":"ctrl+a"}' "$(action_for_key "a")"
}

function test_a_key_outside_the_table_only_closes_the_popup() {
  assert_same '{"close":true}' "$(action_for_key "q")"
}

function test_keys_kept_for_later_steps_only_close_the_popup() {
  local key
  for key in b "[" r R H J K L u; do
    assert_same '{"close":true}' "$(action_for_key "$key")"
  done
  assert_same '{"close":true}' "$(action_for_key "k" "control")"
  assert_same '{"close":true}' "$(action_for_key "l" "control")"
}

function test_a_plain_table_key_with_ctrl_held_only_closes_the_popup() {
  assert_same '{"close":true}' "$(action_for_key "v" "control")"
}

function test_a_table_key_with_cmd_held_only_closes_the_popup() {
  assert_same '{"close":true}' "$(action_for_key "c" "platform")"
}

# Prints, as JSON, what the popup does when the key in $1 is pressed after
# the prefix. $2 lists the modifiers held, such as "control", when set.
# $3 names the last tab, when there is one.
action_for_key() {
  KEY="$1" MODIFIERS="$2" LAST_TAB="$3" run_with_keymap '
    const { actionFor } = await import(process.env.KEYMAP);
    const held = process.env.MODIFIERS.split(",");
    const modifiers = Object.fromEntries(
      ["shift", "control", "alt", "platform", "function"].map((name) => [name, held.includes(name)]),
    );
    const key = process.env.KEY;
    const event = { key, key_char: modifiers.control || key.length > 1 ? undefined : key, modifiers };
    console.log(JSON.stringify(actionFor(event, process.env.LAST_TAB || undefined)));
  '
}

# Prints the keys that the popup shows for the action labelled $1.
popup_keys_for() {
  LABEL="$1" run_with_keymap '
    const { helpGroups } = await import(process.env.KEYMAP);
    const rows = helpGroups().flatMap(({ rows }) => rows);
    console.log(rows.find(({ label }) => label === process.env.LABEL)?.keys ?? "");
  '
}

# Prints the titles of the groups that the popup shows, in order.
popup_groups() {
  run_with_keymap '
    const { helpGroups } = await import(process.env.KEYMAP);
    console.log(helpGroups().map(({ title }) => title).join(" "));
  '
}

# Prints the last tab after the prefix opens in each tab of $1, a list of
# space:tab pairs. The last tab belongs to the space of the final pair.
# $2 lists the tabs still open, when set. Otherwise every tab in $1 is open.
last_tab_after_opens() {
  OPENS="$1" OPEN_TABS="$2" run_with_keymap '
    const { rememberTab, lastTab } = await import(process.env.KEYMAP);
    const opens = process.env.OPENS.split(" ").map((pair) => {
      const [space, tab] = pair.split(":");
      return { space, tab };
    });
    const spaces = opens.map(({ space }) => space);
    const history = opens.reduce((history, here) => rememberTab(history, here, spaces), {});
    const here = opens.at(-1);
    const open = process.env.OPEN_TABS ? process.env.OPEN_TABS.split(" ") : opens.map(({ tab }) => tab);
    console.log(lastTab(history, here, open) ?? "");
  '
}

# Prints the spaces that the history keeps after the prefix opens in each
# tab of $1, a list of space:tab pairs. $2 lists the spaces still open.
spaces_in_history_after_opens() {
  OPENS="$1" OPEN_SPACES="$2" run_with_keymap '
    const { rememberTab } = await import(process.env.KEYMAP);
    const open = process.env.OPEN_SPACES.split(" ");
    const history = process.env.OPENS.split(" ").reduce((history, pair) => {
      const [space, tab] = pair.split(":");
      return rememberTab(history, { space, tab }, open);
    }, {});
    console.log(Object.keys(history).join(" "));
  '
}

# Runs the JavaScript module in $1 with node. KEYMAP holds the path of the
# file under test.
run_with_keymap() {
  KEYMAP="$KEYMAP" mise x node@latest -- node --input-type=module -e "$1"
}
