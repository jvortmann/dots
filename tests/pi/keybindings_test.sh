#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
KEYBINDINGS="$ROOT/pi/keybindings.json"

function set_up() {
  [[ -f $KEYBINDINGS ]] || bashunit::fail "missing the file under test: $KEYBINDINGS"
}

# In Herdr, ctrl-k moves the pane, and keys.json sends ctrl-alt-k for
# ctrl-a ctrl-k. Outside Herdr, ctrl-k still deletes.
function test_pi_deletes_to_the_end_of_the_line_on_ctrl_k_and_ctrl_alt_k() {
  assert_same "ctrl+k ctrl+alt+k" "$(keys tui.editor.deleteToLineEnd)"
}

# In Herdr, ctrl-j moves the pane, and keys.json sends ctrl-alt-j for
# ctrl-a ctrl-j. Outside Herdr, ctrl-j still adds a line.
function test_pi_adds_a_line_on_shift_enter_ctrl_j_and_ctrl_alt_j() {
  assert_same "shift+enter ctrl+j ctrl+alt+j" "$(keys tui.input.newLine)"
}

# Prints the keys that keybindings.json gives the action $1, on one line.
keys() {
  jq -r --arg action "$1" '.[$action] | if type == "array" then join(" ") else . end' "$KEYBINDINGS"
}
