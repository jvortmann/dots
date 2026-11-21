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
