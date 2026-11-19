#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONFIG="$ROOT/herdr-core/config.toml"
HOMEBREW_ZSH=/opt/homebrew/bin/zsh
HC="$HOME/.local/bin/hc"

function set_up() {
  SOCKET=""
  [[ -f $CONFIG ]] || bashunit::fail "missing the file under test: $CONFIG"
  [[ -x $HOMEBREW_ZSH ]] || bashunit::skip "needs Homebrew zsh"
  [[ -x $HC ]] || bashunit::skip "needs the herdr-core CLI"
  SCRATCH=$(bashunit::temp_dir "hc")
  mkdir -p "$SCRATCH/config" "$SCRATCH/home"
  ln -s "$ROOT/herdr-core" "$SCRATCH/config/herdr-core"
  SESSION="bashunit-$$-$RANDOM"
  # The bashunit temp path gives a socket path of 203 bytes. The limit is 103.
  SOCKET="/tmp/$SESSION.sock"
}

function tear_down() {
  [[ -n $SOCKET ]] || return 0
  hc server stop > /dev/null 2>&1 || true
  rm -f "$SOCKET"
}

function test_a_new_terminal_runs_the_homebrew_zsh() {
  start_core
  open_terminal "print -r -- \$ZSH_VERSION > \$HOME/version"

  assert_same "$("$HOMEBREW_ZSH" -f -c 'echo $ZSH_VERSION')" "$(wait_for "$SCRATCH/home/version")"
}

function test_a_new_terminal_runs_a_login_shell() {
  start_core
  open_terminal "[[ -o login ]] && print login > \$HOME/login || print other > \$HOME/login"

  assert_same "login" "$(wait_for "$SCRATCH/home/login")"
}

function test_a_lost_terminal_shows_its_last_screen_above_the_new_shell() {
  start_core
  run_kept_terminal saved-line-1 saved-line-2
  hc server stop > /dev/null
  start_core

  assert_same $'saved-line-1\nsaved-line-2' "$(screen_of_new_shell | head -2)"
}

# Start a scratch core with an empty home, so that no zsh config of the user
# loads. In the scratch XDG_CONFIG_HOME, herdr-core links to the dots folder,
# so the core reads the dots config. SHELL is /bin/zsh, so a core that
# ignores the config runs /bin/zsh.
start_core() {
  in_scratch SHELL=/bin/zsh "$HC" server start > /dev/null
}

# Open a terminal with no command, so that the core starts its configured
# shell. The probe sits in .zshenv, which every zsh reads.
open_terminal() {
  printf '%s\n' "$1" > "$SCRATCH/home/.zshenv"
  hc run --bg > /dev/null
}

# Print the lines in a terminal that the core keeps, then wait until its
# screen shows them. A stop of the core loses a kept program, and the next
# start replaces it with the configured shell. The probe in .zshenv marks the
# start of that shell.
run_kept_terminal() {
  printf '%s\n' 'print started > $HOME/started' > "$SCRATCH/home/.zshenv"
  hc run --bg --keep --name lost -- /bin/sh -c 'printf "%s\n" "$@"; exec sleep 60' sh "$@" > /dev/null
  for _ in {1..50}; do
    [[ $(hc read --lines 0 lost) == *"${!#}"* ]] && break
    sleep 0.1
  done
}

# Wait for the shell that replaced the lost program, then for its prompt.
screen_of_new_shell() {
  local screen
  wait_for "$SCRATCH/home/started" > /dev/null
  for _ in {1..50}; do
    screen=$(hc read --lines 0 lost)
    [[ $screen =~ %\ *$ ]] && break
    sleep 0.1
  done
  printf '%s\n' "$screen"
}

hc() {
  in_scratch "$HC" "$@"
}

in_scratch() {
  env -u XDG_RUNTIME_DIR HOME="$SCRATCH/home" \
    XDG_CONFIG_HOME="$SCRATCH/config" XDG_STATE_HOME="$SCRATCH/state" \
    HC_SESSION="$SESSION" HC_SOCKET="$SOCKET" "$@"
}

wait_for() {
  local file=$1
  for _ in {1..50}; do
    [[ -s $file ]] && break
    sleep 0.1
  done
  cat "$file" 2> /dev/null
}
