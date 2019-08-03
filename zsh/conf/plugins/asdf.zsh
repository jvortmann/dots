# vim: ft=zsh

source "/usr/local/opt/asdf/asdf.sh"

version_info() {
  local language_name=$1
  local info="$(asdf current $language_name 2> /dev/null)"

  if [[ $info =~ $PWD ]]; then
    local version="$(echo $info | cut -d' ' -f1)"

    echo "[$language_name:$version]"
  else
    echo ""
  fi
}
