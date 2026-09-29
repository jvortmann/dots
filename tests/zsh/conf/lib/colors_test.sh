#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel)"
COLORS="$ROOT/zsh/conf/lib/colors"
HOMEBREW_ZSH=/opt/homebrew/bin/zsh

# Source the colors file in a plain zsh, and print each variable it sets as
# NAME=value, with the escape codes quoted so they compare as text.
colors_as_set_by_the_file() {
  TERM=xterm-256color "$HOMEBREW_ZSH" -f -c '
    source "$1"
    for name in RED GREEN YELLOW HI_YELLOW BLUE HI_BLUE LIGHT_BLUE MAGENTA CYAN \
      ORANGE LIGHT_BROWN BROWN PURPLE DEEP_PURPLE BOLD RESET; do
      print -r -- "$name=${(q+)${(P)name}}"
    done
  ' _ "$COLORS"
}

# The same list, with each value built from what tput prints for it.
colors_as_tput_prints_them() {
  TERM=xterm-256color "$HOMEBREW_ZSH" -f -c '
    for name code in RED 1 GREEN 2 YELLOW 3 HI_YELLOW 220 BLUE 4 HI_BLUE 32 \
      LIGHT_BLUE 39 MAGENTA 5 CYAN 6 ORANGE 9 LIGHT_BROWN 215 BROWN 173 \
      PURPLE 99 DEEP_PURPLE 26; do
      value="%{$(tput setaf $code)%}"
      print -r -- "$name=${(q+)value}"
    done
    value="%{$(tput bold)%}"; print -r -- "BOLD=${(q+)value}"
    value="%{$(tput sgr0)%}"; print -r -- "RESET=${(q+)value}"
  '
}

function set_up() {
  [[ -x $HOMEBREW_ZSH ]] || bashunit::skip "needs Homebrew zsh"
}

function test_each_color_holds_the_escape_code_tput_prints() {
  assert_same "$(colors_as_tput_prints_them)" "$(colors_as_set_by_the_file)"
}

function test_loading_the_colors_starts_no_tput_process() {
  local bin calls
  bin=$(bashunit::temp_dir "fake_tput")
  calls="$bin/calls"
  printf '#!/bin/sh\necho "$*" >> "%s"\n' "$calls" > "$bin/tput"
  chmod +x "$bin/tput"

  PATH="$bin:$PATH" TERM=xterm-256color "$HOMEBREW_ZSH" -f -c 'source "$1"' _ "$COLORS"

  assert_empty "$(cat "$calls" 2> /dev/null)"
}
