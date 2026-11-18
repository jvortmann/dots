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
  cp "$ROOT/herdr-app/settings.json" "$DOTS/herdr-app/settings.json"
  ln -s "$DOTS" "$HOME_DIR/.dots"
  SETTINGS="$DOTS/herdr-app/settings.json"
}

function test_a_swap_to_light_fixes_the_herdr_app_appearance_to_light() {
  swap_theme_from_to dark light

  assert_same '"light"' "$(jq -c '.appearance' "$SETTINGS")"
}

function test_a_swap_to_dark_fixes_the_herdr_app_appearance_to_dark() {
  swap_theme_from_to dark light
  swap_theme_from_to light dark

  assert_same '"dark"' "$(jq -c '.appearance' "$SETTINGS")"
}

function test_a_swap_keeps_every_other_herdr_app_setting() {
  swap_theme_from_to dark light

  assert_same "$(jq -S -c . "$ROOT/herdr-app/settings.json")" \
    "$(jq -S -c 'del(.appearance)' "$SETTINGS")"
}

function test_a_swap_leaves_herdr_app_settings_that_jq_cannot_read_as_they_were() {
  printf '{"zoom": 1.2,\n' > "$SETTINGS"

  swap_theme_from_to dark light

  assert_same '{"zoom": 1.2,' "$(cat "$SETTINGS")"
}

function test_a_swap_that_jq_cannot_finish_leaves_no_file_beside_the_herdr_app_settings() {
  printf '{"zoom": 1.2,\n' > "$SETTINGS"

  swap_theme_from_to dark light

  assert_same "settings.json" "$(ls -A "$DOTS/herdr-app")"
}

# Every path the swap edits starts at HOME. The scratch HOME holds only a copy
# of dots with settings.json, so the other gsed calls find no file and the run
# changes no file of the user.
swap_theme_from_to() {
  HOME="$HOME_DIR" "$HOMEBREW_ZSH" -f -c "source ${PLUGIN@Q}; swap-theme-from-to $1 $2" > /dev/null 2>&1
}
