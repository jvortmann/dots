#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
EXTENSION="$ROOT/pi/extensions/herdr-nav.ts"
# shellcheck source=node.sh
source "$ROOT/tests/pi/extensions/node.sh"
# shellcheck source=../../herdr-app/fake_herdr_app.sh
source "$ROOT/tests/herdr-app/fake_herdr_app.sh"

function set_up() {
  [[ -f $EXTENSION ]] || bashunit::fail "missing the file under test: $EXTENSION"
  find_node
  find_pi_tui
  HOME_DIR=$(bashunit::temp_dir "home")
  LOG="$HOME_DIR/herdr-app.log"
  mkdir -p "$HOME_DIR/.local/bin"
  fake_herdr_app ""
}

# The plain form comes from a terminal without the kitty keyboard protocol,
# and the CSI u form from one with it.
# @data_provider keys_and_directions
function test_in_a_herdr_terminal_ctrl_h_j_k_l_move_the_herdr_pane() {
  local key
  printf -v key '%b' "$1"

  run_keys "$key" > /dev/null

  assert_same "do pane.go {\"direction\":\"$2\"}" "$(herdr_app_calls)"
}

function keys_and_directions() {
  bashunit::data_set '\x08' left
  bashunit::data_set '\n' down
  bashunit::data_set '\x0b' up
  bashunit::data_set '\x0c' right
  bashunit::data_set '\e[104;5u' left
  bashunit::data_set '\e[106;5u' down
  bashunit::data_set '\e[107;5u' up
  bashunit::data_set '\e[108;5u' right
}

# Else ctrl-k would also delete to the end of the line in the editor.
function test_in_a_herdr_terminal_a_pane_move_key_does_not_reach_pi() {
  assert_same '{"consume":true}' "$(run_keys $'\x0b')"
}

# pi asks for key release events, and a release of ctrl-k comes as
# \e[107;5:3u. The release must not move the pane a second time.
function test_the_release_of_a_key_moves_no_pane() {
  run_keys $'\e[107;5:3u' > /dev/null

  assert_same "" "$(herdr_app_calls)"
}

# keys.json sends ctrl-alt-k for ctrl-a ctrl-k and ctrl-alt-j for
# ctrl-a ctrl-j, so that pi deletes to the end of the line and adds a line.
function test_other_keys_and_the_ctrl_alt_forms_reach_pi_and_move_no_pane() {
  assert_same $'null\nnull\nnull\nnull' "$(run_keys a $'\r' $'\e[107;7u' $'\e[106;7u')"
  assert_same "" "$(herdr_app_calls)"
}

function test_a_subagent_in_the_same_pi_moves_no_pane() {
  MODE=print run_keys $'\x0b' > /dev/null

  assert_same "" "$(herdr_app_calls)"
}

function test_outside_herdr_pi_keeps_ctrl_h_j_k_l() {
  assert_same "no listener" "$(TERMINAL_ID="" run_keys $'\x0b')"
}

# herdr-app prints {"ok": true}, and pi draws its own screen.
function test_a_pane_move_prints_nothing() {
  assert_not_contains '"ok"' "$(run_keys $'\x0c')"
}

function test_pi_does_not_wait_for_the_pane_move() {
  fake_herdr_app "sleep 2"

  assert_less_than 1000 "$(SHOW_TIME=1 run_keys $'\x0c' | tail -1)"
}

herdr_app_calls() {
  cat "$LOG" 2> /dev/null
}

# Loads the extension in node, in a Herdr terminal with the id t7, and starts
# a session with the mode that MODE names, "tui" by default. Then it sends
# each argument to the terminal input listener of the extension, and prints
# what the listener returns, as JSON, or "no listener". With SHOW_TIME set,
# it also prints how many milliseconds the listener took. Node ends only when
# each herdr-app that the extension started has ended. pi gives the
# extension its own pi-tui, so a resolve hook points node at it. set_up finds
# pi with the real HOME.
run_keys() {
  HOME="$HOME_DIR" HC_TERMINAL_ID=${TERMINAL_ID-t7} EXTENSION="$EXTENSION" PI_TUI="$PI_TUI" \
    MODE=${MODE-tui} \
    "$NODE" --import "$PI_TUI_HOOK" --input-type=module -e '
    const handlers = {};
    (await import(process.env.EXTENSION)).default({ on: (name, handler) => { handlers[name] = handler; } });
    let listener;
    const ui = { onTerminalInput: (handler) => { listener = handler; return () => {}; } };
    await handlers.session_start?.({ type: "session_start" }, { mode: process.env.MODE, ui });
    for (const key of process.argv.slice(1)) {
      const started = Date.now();
      console.log(listener ? JSON.stringify(listener(key) ?? null) : "no listener");
      if (process.env.SHOW_TIME) console.log(Date.now() - started);
    }
  ' "$@" 2>&1
}
