#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
MAIN="$ROOT/herdr-app/mods/tab-bar/main.js"
# shellcheck source=../fixed_colors.sh
source "$ROOT/tests/herdr-app/mods/fixed_colors.sh"

function set_up() {
  [[ -f $MAIN ]] || bashunit::fail "missing the file under test: $MAIN"
}

function test_the_tab_bar_colors_follow_the_theme_in_both_appearances() {
  assert_same "" "$(fixed_colors "$MAIN")"
}

function test_a_tab_takes_the_width_of_its_label_up_to_a_cap() {
  assert_same "" "$(tab_chain | grep -oE '\.w\([0-9]+\)')"
  assert_contains ".max_w(" "$(tab_chain)"
}

function test_a_tab_shows_its_number_then_its_icon_then_its_name() {
  assert_same "number icon text " "$(tab_chain | tab_parts)"
}

function test_no_tab_shows_a_path_named_or_not() {
  assert_contains "const tab = (c) =>" "$(tab_chain)"
  assert_same "" "$(tab_chain | grep -oE '\.cwd\b' | tr '\n' ' ')"
}

function test_the_tabs_the_tray_and_the_space_chip_have_corners_of_at_most_2_px() {
  assert_contains ".rounded(" "$(space_chip_chain)"
  assert_same "" "$({ tab_chain; space_chip_chain; tray_chain; } | round_corners_over 2)"
}

function test_the_space_chip_is_as_tall_as_the_tray_of_the_tabs() {
  assert_contains ".h(" "$(tray_chain)"
  assert_same "$(tray_chain | heights)" "$(space_chip_chain | heights)"
}

function test_the_space_chip_touches_the_tray_of_the_tabs() {
  assert_contains "h_flex()" "$(row_of_the_space_chip)"
  assert_same "" "$(row_of_the_space_chip | gaps)"
  assert_same "" "$({ space_chip_chain; tray_chain; } | margins)"
}

function test_the_bar_keeps_its_space_between_the_parts_on_the_right() {
  assert_contains ".gap(8)" "$(bar_row)"
}

function test_the_status_on_the_right_takes_no_accent_color() {
  assert_same "" "$(grep -oE 't\.accent|C\.status\b' "$MAIN" | tr '\n' ' ')"
}

function test_the_right_side_shows_the_agents_then_the_machine_then_the_time() {
  assert_same "agents needs machine time " "$(right_side | right_parts)"
}

function test_the_agents_that_need_you_take_the_blocked_color() {
  assert_contains "text_color(t.blocked).child(needsText(" "$(right_side)"
}

function test_the_program_icon_is_at_most_18_px() {
  assert_contains "function tile(" "$(tile_function)"
  assert_same "" "$(tile_function | sizes_over 18)"
}

function tab_chain() {
  sed -n '/const tab = (c) =>/,/^    };$/p' "$MAIN"
}

function right_side() {
  sed -n '/\.child(div()\.flex_1())/,$p' "$MAIN"
}

function right_parts() {
  awk '/agentsText\(/ { print "agents" } /needsText\(/ { print "needs" } /machineLabel\(/ { print "machine" } /timeText\(/ { print "time" }' | tr '\n' ' '
}

function tab_parts() {
  awk '/numbers\[space\.id\]/ { print "number" } /tile\(t, C, p\)/ { print "icon" } /\.child\(text\)/ { print "text" }' | tr '\n' ' '
}

function space_chip_chain() {
  sed -n '/\.id("tm-space")/,/space\.name/p' "$MAIN"
}

function tray_chain() {
  sed -n '/space\.name/,/\.children(space\.tabs\.map(tab))/p' "$MAIN" | sed 1d
}

function row_of_the_space_chip() {
  awk '/h_flex\(\)$/ && !/own\(/ { row = ""; on = 1 } on { row = row $0 "\n" } /\.id\("tm-space"\)/ { printf "%s", row; exit }' "$MAIN"
}

function bar_row() {
  sed -n '/return h_flex()/,/\.child(/p' "$MAIN"
}

function gaps() {
  grep -oE '\.gap\([0-9]+\)'
}

function margins() {
  grep -oE '\.m[lrx]?\([0-9]+\)'
}

function heights() {
  grep -oE '\.h\([0-9]+\)'
}

function tile_function() {
  sed -n '/^function tile(/,/^}/p' "$MAIN"
}

function round_corners_over() {
  grep -oE '\.rounded(_full\(\)|\([0-9]+\))' | awk -v max="$1" -F'[()]' '$1 ~ /_full$/ || $2 > max' | tr '\n' ' '
}

function sizes_over() {
  grep -oE '\.(w|h|size)\([0-9]+\)' | awk -v max="$1" -F'[()]' '$2 > max' | tr '\n' ' '
}
