#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
PI_ICON="$ROOT/herdr-app/mods/tab-bar/pi-icon.js"
STOCK_PI="$ROOT/herdr-app/icons/pi.svg"
# shellcheck source=../fixed_colors.sh
source "$ROOT/tests/herdr-app/mods/fixed_colors.sh"

function set_up() {
  [[ -f $PI_ICON ]] || bashunit::fail "missing the file under test: $PI_ICON"
}

function test_draws_the_shape_of_the_stock_pi_icon_in_the_color_it_gets() {
  if [[ ! -f $STOCK_PI ]]; then
    bashunit::skip "the app has not written its icons yet" && return
  fi
  assert_same "$(sed 's/#fff/#123456/g' "$STOCK_PI")" "$(scenario 'console.log(piIcon("#123456").trimEnd());')"
}

function test_writes_the_icon_in_the_color_it_gets_when_there_is_no_icon_yet() {
  assert_same '["write","/app/pi.svg","#123456",null]' "$(scenario '
    await syncPiIcon(files, "/app/pi.svg", "#123456");
    print();')"
}

function test_writes_nothing_when_the_icon_already_has_the_color() {
  assert_same '' "$(scenario '
    file = piIcon("#123456");
    await syncPiIcon(files, "/app/pi.svg", "#123456");
    print();')"
}

function test_replaces_an_icon_of_another_color_only_if_nothing_changed_it_since_the_read() {
  assert_same '["write","/app/pi.svg","#123456","#654321"]' "$(scenario '
    file = piIcon("#654321");
    await syncPiIcon(files, "/app/pi.svg", "#123456");
    print();')"
}

function test_takes_the_icon_that_another_window_wrote_first_as_written() {
  assert_same 'written' "$(scenario '
    files.writeTextFile = async (path, text) => { file = text; throw new Error("stale snapshot"); };
    await syncPiIcon(files, "/app/pi.svg", "#123456").then(() => console.log("written"), (e) => console.log(e.message));')"
}

function test_reports_a_write_that_fails_while_the_icon_keeps_another_color() {
  assert_same 'stale snapshot' "$(scenario '
    files.writeTextFile = async () => { throw new Error("stale snapshot"); };
    await syncPiIcon(files, "/app/pi.svg", "#123456").then(() => console.log("written"), (e) => console.log(e.message));')"
}

function test_has_no_fixed_color_of_its_own() {
  assert_same "" "$(fixed_colors "$PI_ICON")"
}

# Runs the JavaScript in $1 with the exports of pi-icon.js and stand-in file
# calls. readTextFile returns the variable file. print() prints each write as
# one JSON line, with the color of the icon it writes in place of its text.
scenario() {
  PI_ICON="$PI_ICON" mise x node@latest -- node --input-type=module -e "
    const { piIcon, syncPiIcon } = await import(process.env.PI_ICON);
    const writes = [];
    let file = null;
    const files = {
      readTextFile: async () => file,
      writeTextFile: async (path, text, expected) => writes.push(['write', path, colorOf(text), expected === null ? null : colorOf(expected)]),
    };
    const colorOf = (text) => text.match(/fill=\"([^\"]*)\"/)?.[1] ?? text;
    const print = () => writes.forEach((w) => console.log(JSON.stringify(w)));
    $1
  " < /dev/null
}
