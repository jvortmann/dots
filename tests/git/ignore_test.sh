#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
IGNORE="$ROOT/git/ignore"

function set_up() {
  [[ -f $IGNORE ]] || bashunit::fail "missing the file under test: $IGNORE"
  REPO=$(bashunit::temp_dir "repo")
  git init -q "$REPO"
}

function test_ignores_a_core_socket_in_the_herdr_core_folder() {
  assert_same "herdr-core/default.sock" "$(ignored herdr-core/default.sock)"
}

function test_keeps_the_core_config_in_the_herdr_core_folder() {
  assert_same "" "$(ignored herdr-core/config.toml)"
}

function test_keeps_the_own_solarized_themes_in_the_herdr_app_folder() {
  assert_same "" "$(ignored herdr-app/themes/solarized-dark.json)"
  assert_same "" "$(ignored herdr-app/themes/solarized-light.json)"
}

function test_ignores_a_theme_that_the_herdr_app_ships() {
  assert_same "herdr-app/themes/atom-one-dark.json" "$(ignored herdr-app/themes/atom-one-dark.json)"
}

function test_keeps_the_own_copy_mode_mod_in_the_herdr_app_folder() {
  assert_same "" "$(ignored herdr-app/mods/copy-mode/main.js)"
}

function test_keeps_the_own_window_mod_in_the_herdr_app_folder() {
  assert_same "" "$(ignored herdr-app/mods/window/main.js)"
}

function test_keeps_the_own_recent_picker_mod_in_the_herdr_app_folder() {
  assert_same "" "$(ignored herdr-app/mods/recent-picker/main.js)"
}

function test_ignores_the_files_that_the_herdr_app_writes_into_the_window_mod() {
  assert_same "herdr-app/mods/window/jsconfig.json" "$(ignored herdr-app/mods/window/jsconfig.json)"
  assert_same "herdr-app/mods/window/gpui-kit.d.ts" "$(ignored herdr-app/mods/window/gpui-kit.d.ts)"
}

ignored() {
  git -C "$REPO" -c core.excludesFile="$IGNORE" check-ignore "$1"
}
