# vim: ft=zsh

local cache_path="$ZSH_HOME/conf/settings/.yarn_path_cache"
local cache_is_old=$(find "$cache_path" -mtime -1d 2> /dev/null)

if [ ! -r "$cache_is_old" ]; then
  $(yarn global bin > $cache_path)
fi

export PATH="$(cat $cache_path):$PATH"
