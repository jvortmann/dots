#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
# shellcheck source=fixed_colors.sh
source "$ROOT/tests/herdr-app/mods/fixed_colors.sh"

function test_each_icon_of_our_own_mods_takes_the_color_of_its_text() {
  local svg found=""
  for svg in "$ROOT"/herdr-app/mods/{tab-bar,recent-picker,copy-mode,window}/*.svg; do
    [[ -f $svg ]] || continue
    found+="$(fixed_colors "$svg")"
    assert_contains 'stroke="currentColor"' "$(cat "$svg")"
  done
  assert_same "" "$found"
}
