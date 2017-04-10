# vim: ft=zsh

export YARN_PATH_CACHEFILE="$ZSH_HOME/conf/plugins/.yarn_path_cache"

cache "$YARN_PATH_CACHEFILE" "1d" "yarn global bin"

export PATH="$(cat $YARN_PATH_CACHEFILE):$PATH"
