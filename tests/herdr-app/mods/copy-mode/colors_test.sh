#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
MOD="$ROOT/herdr-app/mods/copy-mode"
HC="$HOME/.local/bin/hc"
# shellcheck source=../fixed_colors.sh
source "$ROOT/tests/herdr-app/mods/fixed_colors.sh"

function set_up() {
  SOCKET=""
  [[ -f $MOD/view.sh ]] || bashunit::fail "missing the file under test: $MOD/view.sh"
  [[ -x $HC ]] || bashunit::skip "needs the herdr-core CLI"
  command -v nvim > /dev/null || bashunit::skip "needs nvim"
  SCRATCH=$(bashunit::temp_dir "copy-mode")
  SELECTION='{"fg": "#002b36", "bg": "#b58900"}'
  VIEWER=""
  app_home
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

function test_keeps_the_exact_true_color_of_the_terminal() {
  copy_mode_screen $'\e[38;2;10;200;30mtrue' 'printf "\033[38;2;10;200;30mtrue\033[0m plain\n"'

  assert_contains $'\e[38;2;10;200;30mtrue' "$(cat "$SCRATCH/screen")"
}

function test_keeps_the_256_colors_of_the_terminal() {
  copy_mode_screen $'\e[38;5;208mx' 'printf "\033[38;5;208mx\033[0m plain\n"'

  assert_contains $'\e[38;5;208mx' "$(cat "$SCRATCH/screen")"
}

function test_keeps_bold_italic_and_reverse_text() {
  copy_mode_screen $'\e[7mrev' 'printf "\033[1mbold\033[0m \033[3mital\033[0m \033[7mrev\033[0m plain\n"'

  local screen
  screen=$(cat "$SCRATCH/screen")
  assert_contains $'\e[1mbold' "$screen"
  assert_contains $'\e[3mital' "$screen"
  assert_contains $'\e[7mrev' "$screen"
}

function test_draws_the_history_in_the_default_colors_of_the_app() {
  copy_mode_screen '[150/150]' 'seq 1 150; printf "plain\n"' g g

  assert_not_contains $'\e[48;2;0;0;0m' "$(cat "$SCRATCH/screen")"
}

function test_draws_plain_text_in_the_default_colors_of_the_app() {
  copy_mode_screen $'\e[38;5;1mred' 'printf "\033[31mred\033[0m plain\n"'

  local plain
  plain=$(grep -ao '.\{0,40\}plain' "$SCRATCH/screen")
  assert_contains "plain" "$plain"
  assert_not_contains ';2;' "$plain"
}

function test_draws_the_selection_in_the_colors_that_the_mod_gives() {
  SELECTION='{"fg": "#654321", "bg": "#123456"}'

  copy_mode_screen $'\e[48;2;18;52;86m' 'printf "\033[31mred\033[0m plain\n"' k v l l l

  assert_contains $'\e[38;2;101;67;33m\e[48;2;18;52;86mred' "$(cat "$SCRATCH/screen")"
}

function test_draws_plain_text_in_the_default_colors_when_the_app_shows_copy_mode_in_light() {
  VIEWER="#fdf6e3"

  copy_mode_screen $'\e[38;5;1mred' 'printf "\033[31mred\033[0m plain\n"'

  local plain
  plain=$(grep -ao '.\{0,40\}plain' "$SCRATCH/screen")
  assert_contains "plain" "$plain"
  assert_not_contains ';2;' "$plain"
}

function test_keeps_the_selection_colors_when_the_app_shows_copy_mode_in_light() {
  VIEWER="#fdf6e3"

  copy_mode_screen $'\e[48;2;181;137;0mred' 'printf "\033[31mred\033[0m plain\n"' k v l l l

  assert_contains $'\e[38;2;0;43;54m\e[48;2;181;137;0mred' "$(cat "$SCRATCH/screen")"
}

function test_has_no_fixed_color_of_its_own() {
  assert_same "" "$(fixed_colors "$MOD/nvim.lua")"
}

function test_draws_the_scroll_position_in_the_colors_that_the_mod_gives() {
  SELECTION='{"fg": "#654321", "bg": "#123456"}'

  copy_mode_screen $'\e[48;2;18;52;86m[' 'printf "\033[31mred\033[0m plain\n"'

  assert_contains $'\e[38;2;101;67;33m\e[48;2;18;52;86m[' "$(grep -ao '.\{0,40\}\[[0-9]*/[0-9]*\]' "$SCRATCH/screen")"
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
  view=$(hc run --bg --json --no-parent -- /bin/sh "$SCRATCH/app/mods/copy-mode/view.sh" | jq -r .address)
  for _ in {1..50}; do
    server=$(hc get --json "$view" | jq -r '.labels["copy-mode.standby"] // empty')
    [[ -n $server ]] && break
    sleep 0.1
  done
  in_scratch perl -e 'use POSIX; setsid(); alarm 5; exec @ARGV' \
    nvim --server "$server" --remote-expr "v:lua.copy_mode_open(\"$source\", $SELECTION)" > /dev/null 2>&1
  [[ -n $VIEWER ]] && attach_viewer "$view" "$server"
  [[ $# -gt 0 ]] && hc keys "$view" "$@" > /dev/null
  for _ in {1..25}; do
    in_scratch perl -MTime::HiRes=ualarm -e 'use POSIX; setsid(); ualarm(200000); exec @ARGV' \
      "$HC" attach --observe "$view" > "$SCRATCH/screen" 2> /dev/null || true
    grep -qF "$want" "$SCRATCH/screen" && break
  done
}

# Makes a copy of the app home in $SCRATCH/app with the copy-mode mod.
app_home() {
  mkdir -p "$SCRATCH/app/mods/copy-mode"
  cp "$MOD/view.sh" "$MOD/nvim.lua" "$SCRATCH/app/mods/copy-mode/"
}

# Attaches a viewer with the background $VIEWER to the terminal $1, as the app
# shows copy mode after it opens. The viewer runs `hc attach` in a terminal
# whose display has that background. Waits until the nvim at the server $2
# takes the new background and draws again, and fails when it does not.
attach_viewer() {
  local before
  before=$(in_scratch nvim --server "$2" --remote-expr '&background')
  printf '{"jsonrpc":"2.0","id":1,"method":"terminal.run","params":{"argv":["%s","attach","%s"],"no_parent":true,"no_notify":true,"display":{"bg":"%s"}}}\n' \
    "$HC" "$1" "$VIEWER" | nc -U -w 1 "$SOCKET" > /dev/null
  for _ in {1..30}; do
    [[ $(in_scratch nvim --server "$2" --remote-expr '&background') != "$before" ]] && break
    sleep 0.1
  done
  [[ $(in_scratch nvim --server "$2" --remote-expr '&background') != "$before" ]] ||
    bashunit::fail "nvim kept the background $before"
  in_scratch nvim --server "$2" --remote-expr 'execute("redraw")' > /dev/null
}

hc() {
  in_scratch perl -e 'use POSIX; setsid(); alarm 5; exec @ARGV' "$HC" "$@"
}

in_scratch() {
  env -u XDG_RUNTIME_DIR HOME="$SCRATCH/home" \
    XDG_CONFIG_HOME="$SCRATCH/config" XDG_STATE_HOME="$SCRATCH/state" \
    HC_SESSION="$SESSION" HC_SOCKET="$SOCKET" "$@" < /dev/null
}
