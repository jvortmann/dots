# vim: ft=zsh

# EPOCHREALTIME is a shell parameter, so timing costs no process at all.
zmodload -F zsh/datetime p:EPOCHREALTIME
typeset -gA STARTUP_MARKS
: ${STARTUP_MARKS[init_start]:=$EPOCHREALTIME}

# Configure PATH
source $ZSH_HOME/conf/path
source $ZSH_HOME/conf/xdg

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

: ${STARTUP_MARKS[init_end]:=$EPOCHREALTIME}
(( ${+STARTUP_MARKS[precmd_end]} )) || precmd_functions+=(_startup_timer_stop)
