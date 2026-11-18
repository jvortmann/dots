#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
VIEW="$ROOT/herdr-app/mods/copy-mode/view.sh"
HC="$HOME/.local/bin/hc"

function set_up() {
  SOCKET=""
  [[ -f $VIEW ]] || bashunit::fail "missing the file under test: $VIEW"
  [[ -x $HC ]] || bashunit::skip "needs the herdr-core CLI"
  command -v nvim > /dev/null || bashunit::skip "needs nvim"
  SCRATCH=$(bashunit::temp_dir "copy-mode")
  mkdir -p "$SCRATCH/home/.local/bin"
  ln -s "$HC" "$SCRATCH/home/.local/bin/hc"
  SESSION="bashunit-$$-$RANDOM"
  # The bashunit temp path gives a socket path of 203 bytes. The limit is 103.
  SOCKET="/tmp/$SESSION.sock"
  # The core of the app has this bare PATH, so copy mode must find hc and nvim itself.
  env -i PATH=/usr/bin:/bin:/usr/sbin:/sbin HOME="$SCRATCH/home" XDG_CONFIG_HOME="$SCRATCH/config" XDG_STATE_HOME="$SCRATCH/state" \
    HC_SESSION="$SESSION" HC_SOCKET="$SOCKET" "$HC" server start > /dev/null < /dev/null
}

function tear_down() {
  [[ -n $SOCKET ]] || return 0
  hc server stop > /dev/null 2>&1 || true
  rm -f "$SOCKET"
}

function test_keeps_the_colors_of_the_terminal() {
  copy_mode_screen 'printf "\033[31mred\033[0m plain\n"'

  assert_contains $'\e[38;5;1mred' "$(cat "$SCRATCH/screen")"
}

function test_draws_plain_text_in_the_default_colors_of_the_app() {
  copy_mode_screen 'printf "\033[31mred\033[0m plain\n"'

  assert_not_contains $'\e[38;2;' "$(cat "$SCRATCH/screen")"
}

function test_draws_the_selection_in_dark_text_on_yellow() {
  copy_mode_screen 'printf "\033[31mred\033[0m plain\n"' k v l l l

  assert_contains $'\e[38;5;8m\e[48;5;3mred' "$(cat "$SCRATCH/screen")"
}

# Runs the shell code in $1 in a terminal, opens copy mode on that terminal
# in a second one, presses the other arguments there as keys, and writes the
# bytes that draw copy mode to the file screen.
copy_mode_screen() {
  local source view code=$1
  shift
  source=$(hc run --bg --json --no-parent -- /bin/sh -c "$code; exec sleep 30" | jq -r .address)
  sleep 0.3
  view=$(hc run --bg --json --no-parent -- /bin/sh "$VIEW" "$source" | jq -r .address)
  for _ in {1..30}; do
    hc read "$view" | grep -q plain && break
    sleep 0.1
  done
  # nvim draws the text first and the colors in a later redraw.
  sleep 0.5
  if [[ $# -gt 0 ]]; then
    hc keys "$view" "$@" > /dev/null
    sleep 0.5
  fi
  in_scratch perl -e 'use POSIX; setsid(); alarm 1; exec @ARGV' \
    "$HC" attach --observe "$view" > "$SCRATCH/screen" 2> /dev/null || true
}

hc() {
  in_scratch "$HC" "$@" < /dev/null
}

in_scratch() {
  env -u XDG_RUNTIME_DIR HOME="$SCRATCH/home" \
    XDG_CONFIG_HOME="$SCRATCH/config" XDG_STATE_HOME="$SCRATCH/state" \
    HC_SESSION="$SESSION" HC_SOCKET="$SOCKET" "$@" < /dev/null
}
