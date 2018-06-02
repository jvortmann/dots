# vim: ft=zsh

if [ -d "$HOME/.exenv" ]; then
  export PATH="$HOME/.exenv/bin:$PATH"
  export EXENV_INIT_CACHEFILE="$ZSH_HOME/conf/plugins/.exenv_init_cache"

  cache "$EXENV_INIT_CACHEFILE" "1d" "exenv init -" "export PATH=\"$HOME/.exenv/shims:$PATH\""
fi

# prompt function
elixir_version_info() {
  local name=$(exenv version-name 2> /dev/null)
  local origin=$(exenv version-origin 2> /dev/null)

  if [[ $origin =~ "elixir-version" && $name != "" && $name != "system" ]]; then
    echo "[elixir:$name]"
  else
    echo ""
  fi
}
