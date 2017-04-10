# vim: ft=zsh

if [ -d "$HOME/.rbenv" ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  export RBENV_INIT_CACHEFILE="$ZSH_HOME/conf/plugins/.rbenv_init_cache"

  cache "$RBENV_INIT_CACHEFILE" "1d" "rbenv init -" "export PATH=\"$HOME/.rbenv/shims:$PATH\""
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
