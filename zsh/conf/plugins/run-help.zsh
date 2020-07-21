# vim: ft=zsh

if [ "$(uname -s)" = "Darwin" ]; then
  unalias run-help &> /dev/null
  autoload run-help
  HELPDIR=/usr/local/share/zsh/help
  alias help="run-help"
fi
