# vim: ft=zsh

if [ -d "$HOME/.nodenv" ]; then
  export PATH="$HOME/.nodenv/bin:$PATH"
  export NODENV_INIT_CACHEFILE="$ZSH_HOME/conf/plugins/.nodenv_init_cache"

  cache "$NODENV_INIT_CACHEFILE" "1d" "nodenv init -" "export PATH=\"$HOME/.nodenv/shims:$PATH\""
fi

# prompt function
node_version_info() {
  local name=$(nodenv version-name 2> /dev/null)
  local origin=$(nodenv version-origin 2> /dev/null)

  if [[ $origin =~ "node-version" && $name != "" && $name != "system" ]]; then
    echo "[node:$name]"
  else
    echo ""
  fi
}
