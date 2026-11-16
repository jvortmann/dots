#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT/herdr-app/setup.sh"

function set_up() {
  [[ -f $SCRIPT ]] || bashunit::fail "missing the file under test: $SCRIPT"
  HOME_DIR=$(bashunit::temp_dir "home")
  DOTS="$HOME_DIR/.dots/herdr-app"
  CONFIG="$HOME_DIR/.config/herdr-app"
  mkdir -p "$DOTS"
}

function test_links_the_app_config_folder_to_dots() {
  run_setup

  assert_same "$HOME_DIR/.dots/herdr-app" "$(readlink "$CONFIG")"
}

function test_moves_a_real_config_folder_aside_to_a_backup() {
  mkdir -p "$CONFIG"
  printf '{"width": 800}\n' > "$CONFIG/window.json"

  run_setup

  assert_same '{"width": 800}' "$(cat "$CONFIG.pre-dots/window.json" 2> /dev/null)"
}

function test_links_the_app_config_folder_in_place_of_a_real_one() {
  mkdir -p "$CONFIG"

  run_setup

  assert_same "$HOME_DIR/.dots/herdr-app" "$(readlink "$CONFIG")"
}

function test_a_second_run_puts_no_link_inside_dots() {
  run_setup

  run_setup

  assert_same "" "$(readlink "$DOTS/herdr-app")"
}

function test_keeps_a_new_backup_out_of_an_earlier_one() {
  mkdir -p "$CONFIG" "$CONFIG.pre-dots"

  run_setup

  assert_directory_not_exists "$CONFIG.pre-dots/herdr-app"
}

run_setup() {
  HOME="$HOME_DIR" "$SCRIPT" > /dev/null 2>&1
}
