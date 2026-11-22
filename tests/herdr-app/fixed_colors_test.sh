#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

function set_up() {
  REPO=$(bashunit::temp_dir "repo")
  git init -q "$REPO"
}

function test_our_herdr_files_take_every_color_from_the_theme() {
  assert_same "" "$(fixed_colors_in "$ROOT")"
}

function test_finds_a_hex_color_in_each_kind_of_our_files() {
  plant herdr-app/mods/own/main.js 'const c = "#123456";'
  plant herdr-app/mods/own/nvim.lua 'local c = "#123456"'
  plant herdr-app/mods/own/view.sh 'c="#123456"'
  plant herdr-app/mods/own/icon.svg '<path fill="#123456"/>'
  plant herdr-app/layouts/mine.json '{ "color": "#123456" }'
  plant herdr-app/programs.json '{ "tile": "#123456" }'

  assert_same "herdr-app/layouts/mine.json:1:#123456
herdr-app/mods/own/icon.svg:1:#123456
herdr-app/mods/own/main.js:1:#123456
herdr-app/mods/own/nvim.lua:1:#123456
herdr-app/mods/own/view.sh:1:#123456
herdr-app/programs.json:1:#123456" "$(fixed_colors_in "$REPO")"
}

function test_finds_rgb_and_hsl_colors_and_colors_written_as_0x_numbers() {
  plant herdr-app/mods/own/main.js 'a = rgb(1, 2, 3);
b = rgba(1, 2, 3, 0.5);
c = hsl(1, 2%, 3%);
d = hsla(1, 2%, 3%, 0.5);
e = 0x6c71c4;
f = 0xff6c71c4;'

  assert_same "herdr-app/mods/own/main.js:1:rgb(
herdr-app/mods/own/main.js:2:rgba(
herdr-app/mods/own/main.js:3:hsl(
herdr-app/mods/own/main.js:4:hsla(
herdr-app/mods/own/main.js:5:0x6c71c4
herdr-app/mods/own/main.js:6:0xff6c71c4" "$(fixed_colors_in "$REPO")"
}

function test_finds_colors_written_in_capitals() {
  plant herdr-app/mods/own/main.js 'a = RGB(1, 2, 3);
b = Hsla(1, 2%, 3%, 0.5);
c = 0X6C71C4;'

  assert_same "herdr-app/mods/own/main.js:1:RGB(
herdr-app/mods/own/main.js:2:Hsla(
herdr-app/mods/own/main.js:3:0X6C71C4" "$(fixed_colors_in "$REPO")"
}

function test_finds_a_color_in_a_file_with_a_name_beyond_ascii() {
  plant herdr-app/mods/own/café.js 'const c = "#123456";'

  assert_same "herdr-app/mods/own/café.js:1:#123456" "$(fixed_colors_in "$REPO")"
}

function test_reports_a_tracked_file_that_it_cannot_read() {
  plant herdr-app/mods/own/main.js 'const c = theme().ansi13;'
  rm "$REPO/herdr-app/mods/own/main.js"

  assert_contains "herdr-app/mods/own/main.js:" "$(fixed_colors_in "$REPO")"
}

function test_skips_the_theme_files_where_the_colors_belong() {
  plant herdr-app/themes/own.json '{ "background": "#123456" }'

  assert_same "" "$(fixed_colors_in "$REPO")"
}

function test_skips_the_files_that_git_does_not_track() {
  plant herdr-app/mods/own/main.js 'const c = theme().ansi13;'
  mkdir -p "$REPO/herdr-app/mods/stock"
  printf '%s\n' 'const c = "#123456";' > "$REPO/herdr-app/mods/stock/main.js"
  printf '%s\n' '<path fill="#123456"/>' > "$REPO/herdr-app/mods/own/pi.svg"

  assert_same "" "$(fixed_colors_in "$REPO")"
}

function test_ignores_numbers_and_references_that_have_no_color_form() {
  plant herdr-app/mods/own/main.js 'const flags = 0x10 | 0x7fff;
// Task #78 and the ids #12345 and #1234567.'

  assert_same "" "$(fixed_colors_in "$REPO")"
}

# Writes the text $2 into the file $1 of the repository $REPO, and adds it to
# git, also where the ignore rules of the user would skip it.
plant() {
  mkdir -p "$(dirname "$REPO/$1")"
  printf '%s\n' "$2" > "$REPO/$1"
  git -C "$REPO" add -f "$1"
}

# Prints each fixed color in the Herdr files that git tracks in the repository
# $1, as file:line:match. It finds # with 3, 4, 6 or 8 hex digits, rgb( rgba(
# hsl( hsla( in any case, and 0x or 0X with 6 or 8 hex digits. It skips
# herdr-app/themes and each file that git does not track. Other lengths, such as
# #78 or 0x10, are no color. A tracked file that it cannot read is a finding.
# A word of hex letters after #, such as the Lua length #acc, also matches,
# because #acc is a color too.
fixed_colors_in() {
  git -C "$1" ls-files -z -- herdr-app ':!herdr-app/themes' | while IFS= read -r -d '' file; do
    rg --no-filename -n -o \
      -e '#(?:[0-9a-fA-F]{8}|[0-9a-fA-F]{6}|[0-9a-fA-F]{3,4})\b' \
      -e '\b(?i:rgba?|hsla?)\(' \
      -e '\b0[xX](?:[0-9a-fA-F]{8}|[0-9a-fA-F]{6})\b' \
      "$1/$file" 2>&1 | sed "s|^|$file:|"
  done
}
