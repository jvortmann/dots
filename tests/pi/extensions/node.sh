#!/bin/bash

# Sets NODE to the node of mise, and skips the test when it is missing. It
# runs mise with the real HOME, so a test must run only node with a scratch
# HOME. Mise with a scratch HOME finds no install, and it starts many npm
# processes.
find_node() {
  command -v mise > /dev/null || bashunit::skip "needs mise"
  NODE=$(mise x node@latest -- node -p process.execPath 2> /dev/null)
  [[ -x $NODE ]] || bashunit::skip "needs node from mise"
}

# Sets PI_TUI to the pi-tui of pi, and skips the test when pi is missing. A
# test passes PI_TUI to node with --import of PI_TUI_HOOK, which resolves
# @earendil-works/pi-tui to it.
find_pi_tui() {
  PI_TUI="$(mise where npm:@earendil-works/pi-coding-agent 2> /dev/null)/lib/node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works/pi-tui/dist/index.js"
  [[ -f $PI_TUI ]] || bashunit::skip "needs pi from mise"
  PI_TUI_HOOK="$(dirname "${BASH_SOURCE[0]}")/pi-tui-hook.mjs"
}
