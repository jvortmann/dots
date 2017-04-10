# vim: ft=zsh

if [ -d "$HOME/.rbenv" ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"

  local cache_path="$ZSH_HOME/conf/plugins/.rbenv_init_cache"
  local cache_is_old=$(find "$cache_path" -mtime -1d 2> /dev/null)

  if [ ! -r "$cache_is_old" ]; then
    eval "$(rbenv init -)"
    touch $cache_path
  else
    export PATH="$HOME/.rbenv/shims:$PATH"
  fi
fi

# prompt function
rbenv_prompt_info() {
  local name
  name=$(rbenv version-name 2> /dev/null) || return
  if [[ $name == "system" ]]; then
    echo ""
  else
    echo " [$name]"
  fi
}
