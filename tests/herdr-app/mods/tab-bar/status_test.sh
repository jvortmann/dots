#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
STATUS="$ROOT/herdr-app/mods/tab-bar/status.js"

function set_up() {
  [[ -f $STATUS ]] || bashunit::fail "missing the file under test: $STATUS"
}

function test_shows_the_host_and_time_as_the_tmux_status_line() {
  assert_same "exegol Mon 09/11/26 07:05" "$(status_of 'statusText("exegol", new Date("2026-11-09T07:05:42"))')"
}

function test_shows_only_the_time_while_the_host_is_not_known() {
  assert_same "Mon 09/11/26 07:05" "$(status_of 'statusText("", new Date("2026-11-09T07:05:42"))')"
}

function test_the_clock_waits_until_the_next_minute_starts() {
  assert_same "17500" "$(status_of 'untilNextMinute(new Date("2026-11-09T07:05:42.500"))')"
}

# Prints the value of $1, a call to the exports of status.js, at local time.
status_of() {
  CALL="$1" STATUS="$STATUS" mise x node@latest -- node --input-type=module -e '
    const status = await import(process.env.STATUS);
    console.log(new Function(...Object.keys(status), `return ${process.env.CALL}`)(...Object.values(status)));
  '
}
