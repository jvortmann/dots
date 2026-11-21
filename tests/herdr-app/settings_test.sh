#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SETTINGS="$ROOT/herdr-app/settings.json"
GHOSTTY="$ROOT/ghostty/config"

function set_up() {
  [[ -f $SETTINGS ]] || bashunit::fail "missing the file under test: $SETTINGS"
}

function test_the_system_appearance_picks_the_solarized_light_or_dark_theme() {
  assert_same '{"light":"solarized-light","dark":"solarized-dark"}' \
    "$(jq -c '.theme' "$SETTINGS")"
}

function test_the_terminals_use_the_font_family_of_ghostty() {
  assert_same "$(ghostty_value font-family)" "$(jq -r '.font' "$SETTINGS")"
}

function test_the_terminals_use_the_font_size_of_ghostty_before_the_zoom() {
  assert_same "$(ghostty_value font-size)" "$(number .font_size)"
}

function test_the_terminals_use_the_font_style_of_ghostty() {
  assert_same "$(font_weight "$(ghostty_value font-style)")" "$(number .font_weight)"
}

function test_the_terminals_join_ligatures_as_ghostty_does_by_default() {
  assert_same "true" "$(jq -r '.font_ligatures' "$SETTINGS")"
}

function test_the_panes_show_no_scroll_bar() {
  assert_same "false" "$(jq -r '.pane_scrollbars' "$SETTINGS")"
}

function test_the_appearance_is_fixed_to_light_or_dark_in_the_form_swap_theme_edits() {
  assert_same "1" "$(grep -cE '^  "appearance": "(light|dark)",?$' "$SETTINGS")"
}

# Prints the number at the jq path $1 of settings.json in its plain form. The
# app writes a number such as 16 as 16.0.
number() {
  jq "$1 + 0" "$SETTINGS"
}

# Prints the CSS weight of the Ghostty font style $1.
font_weight() {
  case $1 in
    Thin) echo 100 ;; ExtraLight) echo 200 ;; Light) echo 300 ;; Regular) echo 400 ;;
    Medium) echo 500 ;; SemiBold) echo 600 ;; Bold) echo 700 ;; *) echo "no weight for '$1'" ;;
  esac
}

# Prints the value of the Ghostty key $1, with no quotes.
ghostty_value() {
  sed -nE "s/^$1 *= *\"?([^\"]*)\"?\$/\1/p" "$GHOSTTY"
}
