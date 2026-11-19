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
  copy_mode_screen $'\e[38;5;1mred' 'printf "\033[31mred\033[0m plain\n"'

  assert_contains $'\e[38;5;1mred' "$(cat "$SCRATCH/screen")"
}

function test_draws_plain_text_in_the_default_colors_of_the_app() {
  copy_mode_screen $'\e[38;5;1mred' 'printf "\033[31mred\033[0m plain\n"'

  assert_not_contains $'\e[38;2;' "$(cat "$SCRATCH/screen")"
}

function test_draws_the_selection_in_dark_text_on_yellow() {
  copy_mode_screen $'\e[48;5;3m' 'printf "\033[31mred\033[0m plain\n"' k v l l l

  assert_contains $'\e[38;5;8m\e[48;5;3mred' "$(cat "$SCRATCH/screen")"
}

# Runs the shell code in $2 in a terminal, and opens copy mode on that
# terminal in a warm nvim, the way the mod does. Presses the other arguments
# there as keys. Writes the bytes that draw copy mode to the file screen. It
# stops when they hold the text in $1, or after about 5 seconds.
copy_mode_screen() {
  local source view server want=$1 code=$2
  shift 2
  source=$(hc run --bg --json --no-parent -- /bin/sh -c "$code; exec sleep 30" | jq -r .address)
  for _ in {1..50}; do
    hc read "$source" | grep -q plain && break
    sleep 0.1
  done
  view=$(hc run --bg --json --no-parent -- /bin/sh "$VIEW" | jq -r .address)
  for _ in {1..50}; do
    server=$(hc get --json "$view" | jq -r '.labels["copy-mode.standby"] // empty')
    [[ -n $server ]] && break
    sleep 0.1
  done
  in_scratch perl -e 'use POSIX; setsid(); alarm 5; exec @ARGV' \
    nvim --server "$server" --remote-expr "v:lua.copy_mode_open(\"$source\")" > /dev/null 2>&1
  [[ $# -gt 0 ]] && hc keys "$view" "$@" > /dev/null
  for _ in {1..25}; do
    in_scratch perl -MTime::HiRes=ualarm -e 'use POSIX; setsid(); ualarm(200000); exec @ARGV' \
      "$HC" attach --observe "$view" > "$SCRATCH/screen" 2> /dev/null || true
    grep -qF "$want" "$SCRATCH/screen" && break
  done
}

hc() {
  in_scratch perl -e 'use POSIX; setsid(); alarm 5; exec @ARGV' "$HC" "$@"
}

in_scratch() {
  env -u XDG_RUNTIME_DIR HOME="$SCRATCH/home" \
    XDG_CONFIG_HOME="$SCRATCH/config" XDG_STATE_HOME="$SCRATCH/state" \
    HC_SESSION="$SESSION" HC_SOCKET="$SOCKET" "$@" < /dev/null
}
