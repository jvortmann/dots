# vim: ft=zsh

export NVM_DIR=~/.nvm
source "$BREW_PREFIX/opt/nvm/nvm.sh"

# prompt function
node_version_info() {
  if [[ -d "node_modules" ]] || [[ -r ".nvmrc" ]]; then
    local name=$(nvm version 2> /dev/null | cut -d'v' -f2)
    echo "[node:$name]"
  else
    echo ""
  fi
}
