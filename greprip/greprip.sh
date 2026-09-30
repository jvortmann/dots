# vim: ft=sh

# Sourced by bash in agent shells and by zsh. The function keyword keeps zsh
# from expanding an alias of the same name when it defines the function. Each
# call checks for the tool, since zsh can source this before mise is on PATH.

# Route grep to ripgrep through grg, from greprip-rs, when it is installed.
# A ripgrep config, such as one with --smart-case, would change what grep
# matches, so it stays out.
function grep {
  local arg
  command -v grg > /dev/null 2>&1 || { command grep "$@"; return; }
  for arg in "$@"; do
    # grg passes -A1 to ripgrep, which rejects it. -A 1 works.
    case $arg in -*[ABC][0-9]*) command grep "$@"; return ;; esac
  done
  RIPGREP_CONFIG_PATH= grg "$@"
}

# Route find to fd through fnd, from greprip-rs, when it is installed.
function find {
  local arg
  command -v fnd > /dev/null 2>&1 || { command find "$@"; return; }
  for arg in "$@"; do
    # fnd drops -newer and lists older files too, with no error.
    case $arg in -newer*) command find "$@"; return ;; esac
  done
  fnd "$@"
}
