#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
OPEN="$ROOT/herdr-app/mods/copy-mode/open.js"

function set_up() {
  [[ -f $OPEN ]] || bashunit::fail "missing the file under test: $OPEN"
  command -v node > /dev/null || bashunit::skip "needs node"
}

function test_leaves_copy_mode_shown_in_the_pane() {
  assert_same '["terminal.show",{"terminal":"t9","pane":"p1"}]' "$(open_copy_mode true | app_commands)"
}

function test_gives_the_keyboard_back_to_the_pane_when_the_app_never_sees_the_terminal() {
  assert_same '["terminal.kill",{"terminal":"t9"}]
["pane.focus",{"pane":"p1"}]
["error","the app did not see t9 start"]' "$(open_copy_mode false | app_commands)"
}

function test_sends_the_keys_typed_while_nvim_starts_to_nvim_in_order() {
  local early='[{"key_char":"k","keystroke":"k"},{"key_char":"$","keystroke":"shift-4"},{"keystroke":"escape"}]'

  assert_same '["hc","keys","t9","k","esc"]' "$(open_copy_mode true "$early" | grep '^\["hc","keys"')"
}

function test_reports_keys_that_hc_cannot_send_to_nvim() {
  HC_KEYS_FAILS=true

  assert_same '["error","no such terminal"]' "$(open_copy_mode true '[{"key_char":"k","keystroke":"k"}]' | grep '^\["error"')"
}

# Runs openCopyMode on the terminal t7 in the pane p1, with a stand-in for
# the app whose hc run starts t9. $1 says whether the app comes to know t9,
# and $2 holds the early key events as JSON. When HC_KEYS_FAILS is true,
# hc keys fails. Prints each call to the app and each error as one JSON line.
open_copy_mode() {
  KNOWN="$1" EARLY="${2:-[]}" HC_KEYS_FAILS="${HC_KEYS_FAILS:-false}" node --input-type=module -e "
    import { openCopyMode } from '$OPEN';
    const calls = [];
    const app = {
      hc: async (args) => {
        calls.push(['hc', ...args]);
        if (args[0] === 'keys' && process.env.HC_KEYS_FAILS === 'true') return { code: 1, stdout: '', stderr: 'no such terminal' };
        return { code: 0, stdout: args[0] === 'run' ? '{\"address\":\"t9\"}' : '', stderr: '' };
      },
      run: (name, args) => calls.push([name, args]),
      terminals: () => (process.env.KNOWN === 'true' ? [{ address: 't9' }] : []),
      sleep: async () => {},
    };
    try {
      await openCopyMode(app, { source: 't7', pane: 'p1', view: '/v.sh', early: JSON.parse(process.env.EARLY) });
    } catch (error) {
      calls.push(['error', error.message]);
    }
    for (const call of calls) console.log(JSON.stringify(call));
  " < /dev/null
}

# Keeps only the commands that copy mode runs in the app.
app_commands() {
  grep -v '^\["hc"'
}
