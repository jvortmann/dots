#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
GLYPH="$ROOT/herdr-app/mods/tab-bar/glyph.js"
LIGHT="#fdf6e3"
DARK="#002b36"

function set_up() {
  [[ -f $GLYPH ]] || bashunit::fail "missing the file under test: $GLYPH"
}

function test_on_a_light_canvas_a_white_glyph_takes_the_color_of_its_dark_tile() {
  assert_same "#1c1d21" "$(glyph_color '{"color":"#ffffff","tile":"#1c1d21"}' "$LIGHT")"
}

function test_on_a_dark_canvas_a_white_glyph_stays_white_as_before() {
  assert_same "#ffffff" "$(glyph_color '{"color":"#ffffff","tile":"#1c1d21"}' "$DARK")"
}

function test_on_a_dark_canvas_a_glyph_takes_its_tile_color_when_the_tile_stands_out_enough() {
  assert_same "#57a143" "$(glyph_color '{"color":"#ffffff","tile":"#57a143"}' "$DARK")"
}

function test_the_pi_glyph_takes_the_violet_of_the_theme_on_both_canvases() {
  local pi='{"key":"pi","color":"#ffffff","tile":"#1c1d21"}' theme='{"ansi13":"#6c71c4"}'
  assert_same "#6c71c4" "$(glyph_color "$pi" "$DARK" "$theme")"
  assert_same "#6c71c4" "$(glyph_color "$pi" "$LIGHT" "$theme")"
}

function test_another_agent_on_a_near_black_tile_keeps_white_on_a_dark_canvas() {
  assert_same "#ffffff" "$(glyph_color '{"key":"claude","color":"#ffffff","tile":"#1c1d21"}' "$DARK" '{"ansi13":"#6c71c4"}')"
}

function test_a_glyph_with_no_color_of_its_own_takes_the_text_color_of_the_theme() {
  assert_same "fallback" "$(glyph_color '{}' "$LIGHT")"
}

# Prints the color that the program in $1, as JSON, draws its glyph in on
# the background $2, with the theme colors in $3, as JSON.
glyph_color() {
  GLYPH="$GLYPH" mise x node@latest -- node --input-type=module -e '
    const { glyphColor } = await import(process.env.GLYPH);
    console.log(String(glyphColor(JSON.parse(process.argv[1]), process.argv[2], "fallback", JSON.parse(process.argv[3]))));
  ' "$1" "$2" "${3:-{\}}"
}
