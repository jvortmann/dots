#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
KEYS="$ROOT/herdr-app/keys.json"

function set_up() {
  [[ -f $KEYS ]] || bashunit::fail "missing the file under test: $KEYS"
}

# The nav mod sends the key on to nvim, and moves the pane in other programs.
function test_ctrl_h_j_k_l_in_a_terminal_go_left_down_up_and_right_through_the_nav_mod() {
  assert_same "nav.left nav.down nav.up nav.right" \
    "$(jq -r '.terminal | [."ctrl-h", ."ctrl-j", ."ctrl-k", ."ctrl-l"] | join(" ")' "$KEYS")"
}

function test_f2_in_a_terminal_goes_to_the_program() {
  assert_same '"terminal"' "$(binding terminal "f2")"
}

function test_f2_renames_no_tab() {
  assert_same "" "$(jq -r '[.[] | to_entries[] | select(.key == "f2" and .value == "tab.rename") | .key] | join(" ")' "$KEYS")"
}

function test_no_key_opens_or_feeds_a_prefix_mod() {
  assert_same "" "$(jq -r '[(keys[] | select(. == "mod:prefix")),
    (.[] | to_entries[] | select(.value | tostring | test("prefix")) | .key)] | join(" ")' "$KEYS")"
}

function test_prefix_c_and_prefix_ctrl_c_open_a_new_tab() {
  assert_same '"tab.new"' "$(binding global "ctrl-a c")"
  assert_same '"tab.new"' "$(binding global "ctrl-a ctrl-c")"
}

function test_prefix_v_bar_and_backslash_split_the_pane_to_the_right() {
  assert_same '"pane.split:right"' "$(binding global "ctrl-a v")"
  assert_same '"pane.split:right"' "$(binding global "ctrl-a |")"
  assert_same '"pane.split:right"' "$(binding global "ctrl-a \\")"
}

function test_prefix_s_dash_and_underscore_split_the_pane_down() {
  assert_same '"pane.split:down"' "$(binding global "ctrl-a s")"
  assert_same '"pane.split:down"' "$(binding global "ctrl-a -")"
  assert_same '"pane.split:down"' "$(binding global "ctrl-a _")"
}

function test_prefix_capital_a_and_comma_rename_the_tab() {
  assert_same '"tab.rename"' "$(binding global "ctrl-a shift-a")"
  assert_same '"tab.rename"' "$(binding global "ctrl-a ,")"
}

function test_prefix_h_j_k_l_go_to_the_pane_left_down_up_and_right() {
  assert_same '"pane.go:left"' "$(binding global "ctrl-a h")"
  assert_same '"pane.go:down"' "$(binding global "ctrl-a j")"
  assert_same '"pane.go:up"' "$(binding global "ctrl-a k")"
  assert_same '"pane.go:right"' "$(binding global "ctrl-a l")"
}

function test_prefix_ctrl_h_goes_to_the_pane_left() {
  assert_same '"pane.go:left"' "$(binding global "ctrl-a ctrl-h")"
}

# In Herdr, the nav mod moves the pane on ctrl-j, and pi adds a line on
# ctrl-alt-j.
function test_prefix_ctrl_j_in_a_terminal_sends_ctrl_alt_j_in_the_csi_u_form() {
  assert_same '"send:\u001b[106;7u"' "$(binding terminal "ctrl-a ctrl-j")"
  assert_same "null" "$(binding global "ctrl-a ctrl-j")"
}

function test_prefix_z_zooms_the_pane() {
  assert_same '"pane.zoom"' "$(binding global "ctrl-a z")"
}

function test_prefix_x_closes_the_pane() {
  assert_same '"pane.close"' "$(binding global "ctrl-a x")"
}

function test_prefix_ampersand_closes_the_tab() {
  assert_same '"tab.close"' "$(binding global "ctrl-a &")"
}

function test_prefix_n_and_p_go_to_the_next_and_previous_tab() {
  assert_same '"tab.next"' "$(binding global "ctrl-a n")"
  assert_same '"tab.prev"' "$(binding global "ctrl-a p")"
}

function test_prefix_less_than_and_greater_than_swap_the_tab_left_and_right_through_the_tab_bar() {
  assert_same '"tab-bar.swap-left"' "$(binding global "ctrl-a <")"
  assert_same '"tab-bar.swap-right"' "$(binding global "ctrl-a >")"
}

function test_prefix_braces_swap_the_pane_with_the_one_left_and_right() {
  assert_same '"pane.swap:left"' "$(binding global "ctrl-a {")"
  assert_same '"pane.swap:right"' "$(binding global "ctrl-a }")"
}

function test_prefix_ctrl_braces_swap_the_pane_with_the_one_up_and_down() {
  assert_same '"pane.swap:up"' "$(binding global "ctrl-a ctrl-{")"
  assert_same '"pane.swap:down"' "$(binding global "ctrl-a ctrl-}")"
}

function test_prefix_digits_1_to_9_select_the_tab_with_that_number_through_the_tab_bar() {
  local number
  for number in 1 2 3 4 5 6 7 8 9; do
    assert_same "\"tab-bar.select-$number\"" "$(binding global "ctrl-a $number")"
  done
}

function test_cmd_digits_1_to_9_select_the_tab_with_that_number_through_the_tab_bar() {
  local number
  for number in 1 2 3 4 5 6 7 8 9; do
    assert_same "\"tab-bar.select-$number\"" "$(binding global "cmd-$number")"
  done
}

function test_alt_digits_1_to_9_go_to_the_agent_with_that_number_through_the_tab_bar() {
  local number
  for number in 1 2 3 4 5 6 7 8 9; do
    assert_same "\"tab-bar.select-agent-$number\"" "$(binding global "alt-$number")"
  done
}

# The key costs alt-a in two programs: zsh loses accept-and-hold, and nvim loses
# select the whole buffer.
function test_alt_a_opens_the_agent_list_of_the_tab_bar() {
  assert_same '"tab-bar.agents"' "$(binding global "alt-a")"
}

# The open list has the keyboard, so its section wins over global.
function test_alt_a_in_the_agent_list_closes_it() {
  assert_same '"overlay.close"' "$(binding mod:tab-bar "alt-a")"
}

# On macOS, Option types a character in the search field, so a binding takes
# the key before the field. alt-a closes the list, so All is on alt-l.
function test_alt_l_n_w_and_d_in_the_agent_list_pick_all_needs_you_working_and_done() {
  assert_same '"tab-bar.filter-all" "tab-bar.filter-blocked" "tab-bar.filter-working" "tab-bar.filter-done"' \
    "$(binding mod:tab-bar "alt-l") $(binding mod:tab-bar "alt-n") $(binding mod:tab-bar "alt-w") $(binding mod:tab-bar "alt-d")"
}

function test_alt_l_n_w_and_d_stay_free_outside_the_agent_list() {
  assert_same "null null null null" "$(binding global "alt-l") $(binding global "alt-n") $(binding global "alt-w") $(binding global "alt-d")"
}

function test_prefix_f_prefix_ctrl_f_and_cmd_p_open_the_same_picker_of_recent_spaces() {
  assert_same '"mod.open:recent-picker"' "$(binding global "ctrl-a f")"
  assert_same '"mod.open:recent-picker"' "$(binding global "ctrl-a ctrl-f")"
  assert_same '"mod.open:recent-picker"' "$(binding global "cmd-p")"
}

function test_prefix_question_mark_opens_the_help_of_the_app() {
  assert_same '"app.help"' "$(binding global "ctrl-a ?")"
}

function test_prefix_a_in_a_terminal_sends_ctrl_a_to_it() {
  assert_same '"send:\u0001"' "$(binding terminal "ctrl-a a")"
}

# In Herdr, zsh moves the pane on ctrl-l, and it clears on the CSI u form.
function test_prefix_ctrl_l_in_a_terminal_sends_ctrl_l_in_the_csi_u_form() {
  assert_same '"send:\u001b[108;5u"' "$(binding terminal "ctrl-a ctrl-l")"
}

# In Herdr, the nav mod moves the pane on ctrl-k. zsh and pi delete to the end
# of the line on ctrl-alt-k. pi cannot tell the CSI u form of ctrl-k from ctrl-k.
function test_prefix_ctrl_k_in_a_terminal_sends_ctrl_alt_k_in_the_csi_u_form() {
  assert_same '"send:\u001b[107;7u"' "$(binding terminal "ctrl-a ctrl-k")"
}

function test_cmd_k_and_cmd_shift_p_open_the_command_palette() {
  assert_same '"app.palette"' "$(binding global "cmd-k")"
  assert_same '"app.palette"' "$(binding global "cmd-shift-p")"
}

function test_prefix_ctrl_a_selects_the_last_tab_through_the_tab_bar() {
  assert_same '"tab-bar.last-tab"' "$(binding global "ctrl-a ctrl-a")"
}

function test_prefix_left_bracket_opens_the_copy_mode_of_the_focused_terminal() {
  assert_same '"copy-mode.open"' "$(binding global "ctrl-a [")"
}

function test_copy_mode_needs_no_key_to_go_back_to_the_terminal() {
  assert_same "" "$(jq -r '[.[] | to_entries[] | select(.value == "copy-mode.back") | .key] | join(" ")' "$KEYS")"
}

function test_leaves_ctrl_a_alone_unbound() {
  assert_same "" "$(jq -r '[.[] | to_entries[] | select(.key == "ctrl-a") | .key] | join(" ")' "$KEYS")"
}

function test_leaves_ctrl_and_a_digit_to_the_macos_spaces() {
  assert_same "" "$(jq -r '[.[] | keys[] | select(test("^ctrl-[0-9]$"))] | join(" ")' "$KEYS")"
}

# Prints, as JSON, the action that section $1 of keys.json binds to the
# keys in $2, or null when it binds none.
binding() {
  jq -c --arg section "$1" --arg keys "$2" '.[$section][$keys]' "$KEYS"
}
