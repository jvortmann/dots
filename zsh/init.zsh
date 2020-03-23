# vim: ft=zsh

# Configure PATH
source $ZSH_HOME/conf/path

if type gdate > /dev/null; then
  START="$(gdate "+%s%3N")"
fi

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

if type gdate > /dev/null; then
  LAST_COMMAND_TIME=$(($(gdate "+%s%3N")-$START))
fi
