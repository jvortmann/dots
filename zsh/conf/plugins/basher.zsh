# vim: ft=zsh

export PATH="$HOME/.basher/bin:$PATH"
#eval "$(basher init -)"

export BASHER_SHELL=zsh
export BASHER_ROOT="$HOME/.basher"
export PATH="$BASHER_ROOT/cellar/bin:$PATH"
source "$BASHER_ROOT/completions/basher.zsh"
fpath=("$BASHER_ROOT/cellar/completions/zsh" $fpath)
