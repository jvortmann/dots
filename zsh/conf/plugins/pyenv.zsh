# vim: ft=zsh

if [ -d "$HOME/.pyenv" ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"

  export PYENV_INIT_CACHEFILE="$ZSH_HOME/conf/plugins/.pyenv_init_cache"

  cache "$PYENV_INIT_CACHEFILE" "1d" "pyenv init -" "export PATH=\"$HOME/.pyenv/shims:$PATH\""
fi

# prompt function
python_version_info() {
  local name=$(pyenv version-name 2> /dev/null)
  local origin=$(pyenv version-origin 2> /dev/null)

  if [[ $origin =~ "python-version" && $name != "" && $name != "system" ]]; then
    echo "[python:$name]"
  else
    echo ""
  fi
}
