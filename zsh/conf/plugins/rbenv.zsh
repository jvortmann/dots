# vim: ft=zsh

if [ -d "$HOME/.rbenv" ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  export RBENV_INIT_CACHEFILE="$ZSH_HOME/conf/plugins/.rbenv_init_cache"

  cache "$RBENV_INIT_CACHEFILE" "1d" "rbenv init -" "export PATH=\"$HOME/.rbenv/shims:$PATH\""
fi

# prompt function
ruby_version_info() {
  local name=$(rbenv version-name 2> /dev/null)
  local origin=$(rbenv version-origin 2> /dev/null)

  if [[ $origin =~ "ruby-version" && $name != "" && $name != "system" ]]; then
    echo "[ruby:$name]"
  else
    echo ""
  fi
}
