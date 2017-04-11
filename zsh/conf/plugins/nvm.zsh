# vim: ft=zsh

export NVM_DIR=~/.nvm

nvm_activate() {
  source "$BREW_PREFIX/opt/nvm/nvm.sh" --no-use

  update_prompt
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
