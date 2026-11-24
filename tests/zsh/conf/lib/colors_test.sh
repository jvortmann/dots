#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
COLORS="$ROOT/zsh/conf/lib/colors"
HOMEBREW_ZSH=/opt/homebrew/bin/zsh
# shellcheck source=../../../fakes/fakes.sh
source "$ROOT/tests/fakes/fakes.sh"

# Source the colors file in a plain zsh, and print each variable it sets as
# NAME=value, with the escape codes quoted so they compare as text.
colors_as_set_by_the_file() {
  TERM=xterm-256color "$HOMEBREW_ZSH" -f -c '
    source "$1"
    for name in RED GREEN YELLOW BLUE CYAN AMBER STEEL_BLUE SEA_GREEN \
      MEDIUM_PURPLE DEEP_PINK DEEP_SKY_BLUE DARK_ORANGE DODGER_BLUE \
      DARK_SEA_GREEN LIGHT_GOLDENROD DEEP_RED TAN BOLD RESET; do
      print -r -- "$name=${(q+)${(P)name}}"
    done
  ' _ "$COLORS"
}

# The same list, with each value built from what tput prints for it.
colors_as_tput_prints_them() {
  TERM=xterm-256color "$HOMEBREW_ZSH" -f -c '
    for name code in RED 1 GREEN 2 YELLOW 3 BLUE 4 CYAN 6 AMBER 214 \
      STEEL_BLUE 68 SEA_GREEN 85 MEDIUM_PURPLE 97 DEEP_PINK 125 \
      DEEP_SKY_BLUE 38 DARK_ORANGE 166 DODGER_BLUE 27 DARK_SEA_GREEN 71 \
      LIGHT_GOLDENROD 221 DEEP_RED 160 TAN 180; do
      value="%{$(tput setaf $code)%}"
      print -r -- "$name=${(q+)value}"
    done
    value="%{$(tput bold)%}"; print -r -- "BOLD=${(q+)value}"
    value="%{$(tput sgr0)%}"; print -r -- "RESET=${(q+)value}"
  '
}

function set_up() {
  [[ -f $COLORS ]] || bashunit::fail "missing the file under test: $COLORS"
  [[ -x $HOMEBREW_ZSH ]] || bashunit::skip "needs Homebrew zsh"
}

function test_each_color_holds_the_escape_code_tput_prints() {
  assert_same "$(colors_as_tput_prints_them)" "$(colors_as_set_by_the_file)"
}

function test_loading_the_colors_starts_no_tput_process() {
  local bin calls
  bin=$(bashunit::temp_dir "fake_tput")
  calls="$bin/calls"
  fake_program "$bin" tput "$(printf 'echo "$*" >> %q' "$calls")"

  PATH="$bin:$PATH" TERM=xterm-256color "$HOMEBREW_ZSH" -f -c 'source "$1"' _ "$COLORS"

  assert_empty "$(cat "$calls" 2> /dev/null)"
}
