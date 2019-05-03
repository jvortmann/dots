# vim: ft=zsh

fpath=(/usr/local/share/zsh/site-functions /usr/local/share/zsh-completions $fpath)

export BREW_PREFIX=$(brew --prefix)
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
