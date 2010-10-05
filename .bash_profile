# make ls use colors
alias ls="ls -G"
# set up the terminal format
export PS1='\[\033[;32m\]\u@\h\[\033[1;33m\] \w \[\033[;31m\]$(__git_ps1 "(%s)")\$\[\033[00m\] '
# set the terminal colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagacad
# set localhost alias
alias here="localhost"
# set move to be verbose
alias mv="mv -v"
# set the default editor
# needs macvim to use this alias
alias vim="mvim"
alias vi="mvim"
export EDITOR=vim
# set the PATH environment variable
PATH="/usr/local/share:"
PATH="$PATH/usr/local/bin:"
PATH="$PATH/usr/local/sbin:"
PATH="$PATH/usr/bin:"
PATH="$PATH/usr/sbin:"
PATH="$PATH/bin:"
PATH="$PATH/sbin:"
export PATH
# this loads RVM into a shell session.
# needs RVM installed
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"  
# set the bash-completion path
# needs bash-completion installed
if [ -f `brew --prefix`/etc/bash_completion ]; then
	. `brew --prefix`/etc/bash_completion
fi
