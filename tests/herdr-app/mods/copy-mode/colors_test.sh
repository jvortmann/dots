#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
MOD="$ROOT/herdr-app/mods/copy-mode"
HC="$HOME/.local/bin/hc"

# One core serves each test of the file. Each test opens its own terminals,
# and tear_down ends them, so no test sees the terminals of another.
function set_up_before_script() {
  SOCKET=""
  [[ -x $HC ]] && command -v nvim > /dev/null || return 0
  SCRATCH=$(bashunit::temp_dir "copy-mode")
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

function tear_down_after_script() {
  [[ -n $SOCKET ]] || return 0
  hc server stop > /dev/null 2>&1 || true
  rm -f "$SOCKET"
}

function set_up() {
  TERMINALS=()
  [[ -f $MOD/view.sh ]] || bashunit::fail "missing the file under test: $MOD/view.sh"
  [[ -x $HC ]] || bashunit::skip "needs the herdr-core CLI"
  command -v nvim > /dev/null || bashunit::skip "needs nvim"
  WORK=$(bashunit::temp_dir "test")
  SELECTION='{"fg": "#002b36", "bg": "#b58900"}'
  VIEWER=""
}

function tear_down() {
  local terminal
  for terminal in "${TERMINALS[@]}"; do
    hc kill "$terminal" > /dev/null 2>&1 || true
  done
}

function test_keeps_the_colors_and_the_styles_of_the_terminal() {
  copy_mode_screen 'printf "\033[31mred\033[0m \033[38;2;10;200;30mtrue\033[0m \033[38;5;208mx\033[0m \033[1mbold\033[0m \033[3mital\033[0m \033[7mrev\033[0m plain\n"'

  local screen
  screen=$(cat "$WORK/screen")
  assert_contains $'\e[38;5;1mred' "$screen"
  assert_contains $'\e[38;2;10;200;30mtrue' "$screen"
  assert_contains $'\e[38;5;208mx' "$screen"
  assert_contains $'\e[1mbold' "$screen"
  assert_contains $'\e[3mital' "$screen"
  assert_contains $'\e[7mrev' "$screen"
}

function test_draws_the_history_in_the_default_colors_of_the_app() {
  copy_mode_screen 'seq 1 150; printf "plain\n"' g g

  assert_not_contains $'\e[48;2;0;0;0m' "$(cat "$WORK/screen")"
}

function test_draws_the_selection_in_the_colors_that_the_mod_gives() {
  SELECTION='{"fg": "#654321", "bg": "#123456"}'

  copy_mode_screen 'printf "\033[31mred\033[0m plain\n"' k v l l l

  assert_contains $'\e[38;2;101;67;33m\e[48;2;18;52;86mred' "$(cat "$WORK/screen")"
}

function test_draws_plain_text_in_the_default_colors_when_the_app_shows_copy_mode_in_light() {
  VIEWER="#fdf6e3"

  copy_mode_screen 'printf "\033[31mred\033[0m plain\n"'

  local plain
  plain=$(grep -ao '.\{0,40\}plain' "$WORK/screen")
  assert_contains "plain" "$plain"
  assert_not_contains ';2;' "$plain"
}

function test_draws_the_scroll_position_in_the_colors_that_the_mod_gives() {
  SELECTION='{"fg": "#654321", "bg": "#123456"}'

  copy_mode_screen 'printf "\033[31mred\033[0m plain\n"'

  assert_contains $'\e[38;2;101;67;33m\e[48;2;18;52;86m[' "$(grep -ao '.\{0,40\}\[[0-9]*/[0-9]*\]' "$WORK/screen")"
}

# Runs the shell code in $1 in a terminal, and opens copy mode on that
# terminal in a warm nvim, the way the mod does. Presses the other arguments
# there as keys. Writes the bytes that draw copy mode to the file
# $WORK/screen.
copy_mode_screen() {
  local code=$1
  shift
  open_terminals "$code"
  in_scratch perl -e 'use POSIX; setsid(); alarm 5; exec @ARGV' \
    nvim --server "$SERVER" --remote-expr "v:lua.copy_mode_open(\"$SOURCE\", $SELECTION)" > /dev/null 2>&1
  [[ -n $VIEWER ]] && attach_viewer
  press_and_paint "$@"
}

# Starts the terminal SOURCE, which runs the shell code in $1, and the
# terminal VIEW, which runs view.sh. Sets SERVER to the nvim server of VIEW,
# which the core gives in a label of VIEW. Returns when the screen of SOURCE
# shows plain, the last word of the code. The first line of `hc events` lists
# the terminals, and each later line is a change.
open_terminals() {
  local tag="bashunit-$RANDOM" events line
  SERVER=""
  mkfifo "$WORK/events"
  in_scratch perl -e 'use POSIX; setsid(); alarm 5; exec @ARGV' \
    "$HC" events --json --label "test=$tag" > "$WORK/events" 2> /dev/null &
  exec {events}< "$WORK/events"
  read -r -t 5 line <&"$events"
  SOURCE=$(hc run --bg --json --no-parent --label "test=$tag" -- /bin/sh -c "$code; exec cat" | jq -r .address)
  VIEW=$(hc run --bg --json --no-parent --label "test=$tag" -- /bin/sh "$SCRATCH/app/mods/copy-mode/view.sh" | jq -r .address)
  TERMINALS+=("$SOURCE" "$VIEW")
  while [[ -z $SERVER ]] && read -r -t 5 line <&"$events"; do
    [[ $line == *'"terminal":"'"$VIEW"'","type":"labels"'* ]] &&
      SERVER=$(jq -r '.params.data.labels["copy-mode.standby"] // empty' <<< "$line")
  done
  exec {events}<&-
  [[ -n $SERVER ]] || bashunit::fail "view.sh gave no nvim server"
  attach_until "$SOURCE" plain > /dev/null || bashunit::fail "the source terminal did not show plain"
}

# Presses the keys in the arguments in VIEW, and then F12, which redraws and
# echoes a mark. Once an attach shows the mark, the core holds each frame
# that nvim drew for the keys. A fresh attach then paints the whole screen.
# The test needs that first paint, because later updates come in the
# encoding of nvim itself. The first paint ends with ESC ( B, and the file
# $WORK/screen gets each byte up to there.
press_and_paint() {
  local mark="bashunit-drawn-$RANDOM"
  in_scratch perl -e 'use POSIX; setsid(); alarm 5; exec @ARGV' \
    nvim --server "$SERVER" --remote-expr "execute('noremap <F12> <Cmd>redraw<Bar>echo \"$mark\"<CR>')" > /dev/null
  hc keys "$VIEW" "$@" f12 > /dev/null
  attach_until "$VIEW" "$mark" > /dev/null || bashunit::fail "copy mode drew no frame after the keys"
  attach_until "$VIEW" $'\e(B' > "$WORK/screen" || bashunit::fail "the attach gave no first paint"
}

# Prints what `hc attach --observe` sends for the terminal $1, up to the end
# of the first $2 in it. It ends the attach there, and fails when $2 does not
# come within 5 seconds.
attach_until() {
  in_scratch perl -e '
    use POSIX; setsid();
    my $until = shift;
    my $pid = open(my $in, "-|", @ARGV) or die "attach: $!";
    $SIG{ALRM} = sub { kill "TERM", $pid; exit 1 };
    alarm 5;
    my $seen = "";
    while (sysread($in, my $chunk, 65536)) {
      $seen .= $chunk;
      my $at = index($seen, $until);
      next if $at < 0;
      print substr($seen, 0, $at + length $until);
      kill "TERM", $pid;
      exit 0;
    }
    exit 1;
  ' "$2" "$HC" attach --observe "$1"
}

# Makes a copy of the app home in $SCRATCH/app with the copy-mode mod.
app_home() {
  mkdir -p "$SCRATCH/app/mods/copy-mode"
  cp "$MOD/view.sh" "$MOD/nvim.lua" "$SCRATCH/app/mods/copy-mode/"
}

# Attaches a viewer with the background $VIEWER to VIEW, as the app shows
# copy mode after it opens. The viewer runs `hc attach` in a terminal whose
# display has that background. Returns when the nvim at SERVER takes the new
# background, and fails when it does not within 3 seconds.
attach_viewer() {
  local before viewer
  before=$(in_scratch nvim --server "$SERVER" --remote-expr '&background')
  viewer=$(printf '{"jsonrpc":"2.0","id":1,"method":"terminal.run","params":{"argv":["%s","attach","%s"],"no_parent":true,"no_notify":true,"display":{"bg":"%s"}}}\n' \
    "$HC" "$VIEW" "$VIEWER" | nc -U -w 1 "$SOCKET" | jq -r '.result.address // empty')
  TERMINALS+=("$viewer")
  [[ $(in_scratch perl -e 'use POSIX; setsid(); alarm 5; exec @ARGV' \
    nvim --server "$SERVER" --remote-expr "wait(3000, '&background !=# \"$before\"')") == 0 ]] ||
    bashunit::fail "nvim kept the background $before"
}

hc() {
  in_scratch perl -e 'use POSIX; setsid(); alarm 5; exec @ARGV' "$HC" "$@"
}

in_scratch() {
  env -u XDG_RUNTIME_DIR HOME="$SCRATCH/home" \
    XDG_CONFIG_HOME="$SCRATCH/config" XDG_STATE_HOME="$SCRATCH/state" \
    HC_SESSION="$SESSION" HC_SOCKET="$SOCKET" "$@" < /dev/null
}
