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

function test_a_glyph_with_no_color_of_its_own_takes_the_text_color_of_the_theme() {
  assert_same "fallback" "$(glyph_color '{}' "$LIGHT")"
}

# Prints the color that the program in $1, as JSON, draws its glyph in on
# the background $2.
glyph_color() {
  GLYPH="$GLYPH" mise x node@latest -- node --input-type=module -e '
    const { glyphColor } = await import(process.env.GLYPH);
    console.log(String(glyphColor(JSON.parse(process.argv[1]), process.argv[2], "fallback")));
  ' "$1" "$2"
}
