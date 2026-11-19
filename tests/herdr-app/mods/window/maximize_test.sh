#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
MAXIMIZE="$ROOT/herdr-app/mods/window/maximize.js"

function set_up() {
  [[ -f $MAXIMIZE ]] || bashunit::fail "missing the file under test: $MAXIMIZE"
}

function test_a_window_that_is_not_maximized_gets_maximized() {
  assert_same "true" "$(maximize_of '{"maximized": false, "fullscreen": false}')"
}

function test_a_maximized_window_stays_as_it_is() {
  assert_same "false" "$(maximize_of '{"maximized": true, "fullscreen": false}')"
}

function test_a_window_in_full_screen_stays_as_it_is() {
  assert_same "false" "$(maximize_of '{"maximized": false, "fullscreen": true}')"
}

function test_nothing_maximizes_while_the_app_has_no_window() {
  assert_same "false" "$(maximize_of 'null')"
}

# Prints whether the window mod maximizes the window $1, the JSON of window().
maximize_of() {
  WIN="$1" MAXIMIZE="$MAXIMIZE" mise x node@latest -- node --input-type=module -e '
    const { shouldMaximize } = await import(process.env.MAXIMIZE);
    console.log(shouldMaximize(JSON.parse(process.env.WIN)));
  '
}
