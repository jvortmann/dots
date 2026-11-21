#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
PLUGIN="$ROOT/zsh/conf/plugins/theme.zsh"
HOMEBREW_ZSH=/opt/homebrew/bin/zsh

function set_up() {
  [[ -f $PLUGIN ]] || bashunit::fail "missing the file under test: $PLUGIN"
  [[ -x $HOMEBREW_ZSH ]] || bashunit::skip "needs Homebrew zsh"
  HOME_DIR=$(bashunit::temp_dir "home")
  DOTS=$(bashunit::temp_dir "dots")
  mkdir "$DOTS/herdr-app"
  ln -s "$DOTS" "$HOME_DIR/.dots"
  SETTINGS="$DOTS/herdr-app/settings.json"
}

function test_a_swap_to_light_changes_only_the_herdr_app_appearance() {
  settings_with_appearance '"appearance": "dark"' > "$SETTINGS"

  swap_theme_from_to dark light

  assert_same "$(settings_with_appearance '"appearance": "light"')" "$(cat "$SETTINGS")"
}

function test_a_swap_to_dark_changes_only_the_herdr_app_appearance() {
  settings_with_appearance '"appearance": "light"' > "$SETTINGS"

  swap_theme_from_to light dark

  assert_same "$(settings_with_appearance '"appearance": "dark"')" "$(cat "$SETTINGS")"
}

function test_a_swap_leaves_herdr_app_settings_with_no_appearance_unchanged() {
  settings_with_appearance '"sounds": {}' > "$SETTINGS"

  swap_theme_from_to dark light

  assert_same "$(settings_with_appearance '"sounds": {}')" "$(cat "$SETTINGS")"
}

# Every path the swap edits starts at HOME. The scratch HOME holds only the
# settings.json that the test writes, so the other gsed calls find no file and
# the run changes no file of the user.
swap_theme_from_to() {
  HOME="$HOME_DIR" "$HOMEBREW_ZSH" -f -c "source ${PLUGIN@Q}; swap-theme-from-to $1 $2" > /dev/null 2>&1
}

# Herdr app settings as the app writes them, with the given line before the
# theme.
settings_with_appearance() {
  printf '{\n  "zoom": 1.0,\n  "minimum_contrast": 1.0,\n  %s,\n  "theme": {\n    "light": "solarized-light",\n    "dark": "solarized-dark"\n  }\n}\n' "$1"
}
