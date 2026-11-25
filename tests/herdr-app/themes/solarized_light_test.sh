#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
THEME="$ROOT/herdr-app/themes/solarized-light.json"

function set_up() {
  [[ -f $THEME ]] || bashunit::fail "missing the file under test: $THEME"
}

function test_unfocused_pane_lines_are_a_light_hairline_on_the_pane_background() {
  assert_less_or_equal_than 150 "$(contrast_x100 "$(color border)" "$(color background)")"
}

function test_pane_lines_stay_visible_on_the_pane_background() {
  assert_greater_or_equal_than 140 "$(contrast_x100 "$(color border)" "$(color background)")"
}

# Prints the theme color with the name $1, from "colors" or from the top level.
color() {
  jq -er ".colors.$1 // .$1" "$THEME"
}

# Prints the WCAG contrast ratio of the colors $1 and $2, as #rrggbb, times 100.
contrast_x100() {
  awk -v a="$(rgb "$1")" -v b="$(rgb "$2")" '
    function lin(v) { v /= 255; return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ^ 2.4 }
    function lum(s, c) { split(s, c, " "); return 0.2126 * lin(c[1]) + 0.7152 * lin(c[2]) + 0.0722 * lin(c[3]) }
    BEGIN {
      x = lum(a); y = lum(b)
      if (x < y) { t = x; x = y; y = t }
      printf "%.0f\n", (x + 0.05) / (y + 0.05) * 100
    }'
}

# Prints the color $1, as #rrggbb, as three decimal numbers.
rgb() {
  echo "$((16#${1:1:2})) $((16#${1:3:2})) $((16#${1:5:2}))"
}
