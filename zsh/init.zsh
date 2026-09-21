# vim: ft=zsh

# Configure PATH
source $ZSH_HOME/conf/path

# EPOCHREALTIME is a shell parameter, so timing costs no process at all.
zmodload -F zsh/datetime p:EPOCHREALTIME
START=$EPOCHREALTIME

# Read default settings
source $ZSH_HOME/conf/defaults

# Include all files in lib dir
for file ($ZSH_HOME/conf/lib/*) source $file

# Include plugins
source $ZSH_HOME/conf/plugins.zsh

# source all settings files
for file ($ZSH_HOME/conf/settings/*) source $file

source $ZSH_HOME/conf/theme.zsh

source $ZSH_HOME/conf/completion.zsh

typeset -gi LAST_COMMAND_TIME
(( LAST_COMMAND_TIME = (EPOCHREALTIME - START) * 1000 ))
