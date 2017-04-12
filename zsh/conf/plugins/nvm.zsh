# vim: ft=zsh

export NVM_DIR=~/.nvm

nvm_activate() {
  source "$BREW_PREFIX/opt/nvm/nvm.sh" --no-use

  nvm_add_path

  update_prompt
}

nvm_path() {
  echo "${$(nvm which default)%/node}"
}

nvm_add_path(){
  export NVM_PATH_CACHEFILE="$ZSH_HOME/conf/plugins/.nvm_path_cache"

  cache "$NVM_PATH_CACHEFILE" "1d" "nvm_path"

  export PATH="$(< $NVM_PATH_CACHEFILE):$PATH"
}

# prompt function
node_version_info() {
  if [[ -d "node_modules" ]] || [[ -r ".nvmrc" ]]
  then
    if which nvm >& /dev/null
    then
      local name=$(nvm version 2> /dev/null | cut -d'v' -f2)
      echo "[node:$name]"
    else
      echo "[node:nvm inactive]"
    fi
  else
    echo ""
  fi
}
