#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
THEMES="$ROOT/herdr-app/themes"
GHOSTTY_THEMES="$ROOT/ghostty/themes"
APP_COLORS="accent accent_foreground blocked border canvas chrome dim done hover idle input muted popover raised selected solid solid_foreground surface unknown working"

function test_the_dark_theme_has_the_colors_of_the_ghostty_solarized_dark_theme() {
  assert_same "$(ghostty_colors "$GHOSTTY_THEMES/solarized-dark")" \
    "$(herdr_colors "$THEMES/solarized-dark.json")"
}

function test_the_light_theme_has_the_colors_of_the_ghostty_solarized_light_theme() {
  assert_same "$(ghostty_colors "$GHOSTTY_THEMES/solarized-light")" \
    "$(herdr_colors "$THEMES/solarized-light.json")"
}

function test_each_theme_gives_the_app_its_own_color_for_every_part_of_the_window() {
  local theme
  for theme in solarized-dark solarized-light; do
    assert_same "$theme: $APP_COLORS" \
      "$theme: $(jq -r '.colors // {} | keys_unsorted | sort | join(" ")' "$THEMES/$theme.json")"
  done
}

function test_each_theme_takes_the_app_colors_from_its_ghostty_solarized_theme() {
  local theme
  for theme in solarized-dark solarized-light; do
    assert_same "$theme: " "$theme: $(colors_outside_ghostty "$theme")"
  done
}

# Prints each app color of the theme $1 that its Ghostty theme does not hold.
colors_outside_ghostty() {
  jq -r '.colors // {} | to_entries[] | "\(.key) \(.value)"' "$THEMES/$1.json" |
    while read -r name hex; do
      ghostty_colors "$GHOSTTY_THEMES/$1" | grep -q " $hex\$" || printf '%s ' "$name=$hex"
    done
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
