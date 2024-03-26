# vim: ft=zsh

if [[ $(uname -m) = "x86_64" ]]; then
  export BREW_PREFIX=/usr/local
else
fi
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_ANALYTICS=1
