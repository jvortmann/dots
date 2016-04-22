# vim: ft=zsh

# Configure PATH
source $ZSH_HOME/conf/path

if type gdate > /dev/null; then
  START="$(gdate "+%s%3N")"
  #PS4='+$(gdate "+%s:%N") %N:%i> '
  #exec 3>&2 2>/tmp/startlog
  #setopt xtrace prompt_subst
fi

# Read default settings
source $ZSH_HOME/conf/defaults

# Include all files in lib dir
for file ($ZSH_HOME/conf/lib/*) source $file

# Include plugins
for file ($ZSH_HOME/conf/plugins/*) source $file

# Set theme
source $ZSH_HOME/themes/init

source $ZSH_HOME/conf/extras

if type gdate > /dev/null; then
  #unsetopt xtrace
  #exec 2>&3 3>&-
  LAST_COMMAND_TIME=$(($(gdate "+%s%3N")-$START))
fi
