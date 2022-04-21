# vim: ft=zsh

source "/usr/local/opt/asdf/libexec/asdf.sh"

version_info() {
  local language_name=$1
  local version_from_tool_versions=$(grep "$language_name" "$PWD/.tool-versions" &> /dev/null | cut -d' ' -f2)
  local version_from_language_version=$(ls -a "$PWD" | grep ".$language_name-version" | xargs cat &> /dev/null | cut -d'-' -f2)

  if [[ -n $version_from_tool_versions ]]; then
    version_info_tag $language_name $version_from_tool_versions
  else
    if [[ -n $version_from_language_version ]]; then
      version_info_tag $language_name $version_from_language_version
    else
      echo ""
    fi
  fi
}

version_info_tag() {
  echo "[$1:$2]"
}
