#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

function test_each_icon_of_our_own_mods_takes_the_color_of_its_text() {
  local svg
  for svg in "$ROOT"/herdr-app/mods/{tab-bar,recent-picker,copy-mode,window}/*.svg; do
    [[ -f $svg ]] || continue
    git -C "$ROOT" -c core.excludesFile="$ROOT/git/ignore" check-ignore -q "$svg" && continue
    assert_contains 'stroke="currentColor"' "$(cat "$svg")"
  done
}
