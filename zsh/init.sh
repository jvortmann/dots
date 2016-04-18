# vim: ft=zsh

START="$(gdate "+%s%3N")"
#PS4='+$(gdate "+%s:%N") %N:%i> '
#exec 3>&2 2>/tmp/startlog
#setopt xtrace prompt_subst

#set terminal type
export TERM=xterm-256color

# set editor
export EDITOR=nvim

# Enable emacs keys
bindkey -e

# Disable flow control
stty -ixon

# Configure PATH
source $ZSH_HOME/conf/path

# Include all files in lib dir
for file ($ZSH_HOME/conf/lib/*) source $file

# Include plugins
for file ($ZSH_HOME/conf/plugins/*.sh) source $file

# Set theme
source $ZSH_HOME/themes/init

#unsetopt xtrace
#exec 2>&3 3>&-
LAST_COMMAND_TIME=$(($(gdate "+%s%3N")-$START))
