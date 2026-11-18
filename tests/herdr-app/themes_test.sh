#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
THEMES="$ROOT/herdr-app/themes"
GHOSTTY_THEMES="$ROOT/ghostty/themes"

function test_the_dark_theme_has_the_colors_of_the_ghostty_solarized_dark_theme() {
  assert_same "$(ghostty_colors "$GHOSTTY_THEMES/solarized-dark")" \
    "$(herdr_colors "$THEMES/solarized-dark.json")"
}

function test_the_light_theme_has_the_colors_of_the_ghostty_solarized_light_theme() {
  assert_same "$(ghostty_colors "$GHOSTTY_THEMES/solarized-light")" \
    "$(herdr_colors "$THEMES/solarized-light.json")"
}

ghostty_colors() {
  sed -nE \
    -e 's/^(background|foreground) *= *(#[0-9a-f]{6})$/\1 \2/p' \
    -e 's/^cursor-color *= *(#[0-9a-f]{6})$/cursor \1/p' \
    -e 's/^selection-background *= *(#[0-9a-f]{6})$/selection \1/p' \
    -e 's/^palette *= *"([0-9]+)=(#[0-9a-f]{6})"$/ansi\1 \2/p' \
    "$1" | sort
}

herdr_colors() {
  jq -r '"background \(.background)", "foreground \(.foreground)",
    "cursor \(.cursor)", "selection \(.selection)",
    (.ansi | to_entries[] | "ansi\(.key) \(.value)")' "$1" 2>&1 | sort
}
