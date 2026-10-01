# vim: ft=sh

# Sourced by bash in agent shells and by zsh. The function keyword keeps zsh
# from expanding an alias of the same name when it defines the function. Each
# call checks for the tool, since zsh can source this before mise is on PATH.

# Route grep to ripgrep through grg, from greprip-rs, when it is installed.
# A ripgrep config, such as one with --smart-case, would change what grep
# matches, so it stays out.
function grep {
  local arg basic=1
  command -v grg > /dev/null 2>&1 || { command grep "$@"; return; }
  for arg in "$@"; do
    # grg passes -A1 to ripgrep, which rejects it. -A 1 works.
    case $arg in -*[ABC][0-9]*) command grep "$@"; return ;; esac
    case $arg in
      --extended-regexp|--fixed-strings|--perl-regexp) basic= ;;
      --*) ;;
      -*[EFP]*) basic= ;;
    esac
  done
  # A basic regex, the default of grep, reads ? + | { as plain characters.
  # grg passes them on, and ripgrep reads them as operators: ^?? matches every
  # line. Only -E, -F and -P patterns are safe to translate.
  if [ -n "$basic" ]; then
    for arg in "$@"; do
      case $arg in -*) ;; *\?*|*+*|*\|*|*\{*) command grep "$@"; return ;; esac
    done
  fi
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
