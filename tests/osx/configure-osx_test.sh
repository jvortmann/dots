#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIGURE="$ROOT/osx/configure-osx.sh"

function set_up() {
  [[ -f $CONFIGURE ]] || bashunit::fail "missing the file under test: $CONFIGURE"
}

function test_the_herdr_app_opens_on_the_first_space_with_ghostty() {
  assert_same "com.mitchellh.ghostty dev.herdr.app" "$(first_space_apps)"
}

# Prints the bundle ids that the script binds to the first Space, sorted.
first_space_apps() {
  grep -E '"app-bindings" -dict-add "[^"]+" "\$\{spaces\[0\]\}"$' "$CONFIGURE" |
    sed -E 's/.*-dict-add "([^"]+)".*/\1/' | sort | tr '\n' ' ' | sed 's/ $//'
}
