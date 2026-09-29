#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel)"
CONFIG="$ROOT/tmux/tmux.conf"
HOMEBREW_ZSH=/opt/homebrew/bin/zsh

# Start a tmux server of its own, with an empty home so that no plugin loads
# and no saved session comes back. SHELL is /bin/zsh, as in a desktop session
# that began before the login shell changed.
run_in_new_session() {
  local home=$1 command=$2
  HOME="$home" SHELL=/bin/zsh tmux -L "$SERVER" -f "$CONFIG" \
    new-session -d "$command" 2> /dev/null
}

function set_up() {
  [[ -x $HOMEBREW_ZSH ]] || bashunit::skip "needs Homebrew zsh"
  HOME_DIR=$(bashunit::temp_dir "tmux")
  SERVER="bashunit-$$-$RANDOM"
}

function tear_down() {
  tmux -L "$SERVER" kill-server 2> /dev/null || true
}

function test_a_new_pane_runs_the_homebrew_zsh() {
  run_in_new_session "$HOME_DIR" "echo \$ZSH_VERSION > $HOME_DIR/version; sleep 5"
  sleep 1

  assert_same "$("$HOMEBREW_ZSH" -f -c 'echo $ZSH_VERSION')" "$(cat "$HOME_DIR/version")"
}

function test_a_new_pane_does_not_inherit_a_dynamic_library_path() {
  DYLD_LIBRARY_PATH=/opt/homebrew/opt/expat/lib run_in_new_session "$HOME_DIR" \
    "echo \${DYLD_LIBRARY_PATH-unset} > $HOME_DIR/dyld; sleep 5"
  sleep 1

  assert_same "unset" "$(cat "$HOME_DIR/dyld")"
}
