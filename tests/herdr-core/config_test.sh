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
