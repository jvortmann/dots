# vim: ft=zsh

language_info() {
  if declare -f version_info > /dev/null; then
    local _clojure_info="${ORANGE}$(version_info clojure)${RESET}"
    local _elixir_info="${PURPLE}$(version_info elixir)${RESET}"
    local _erlang_info="${MAGENTA}$(version_info erlang)${RESET}"
    local _go_info="${LIGHT_BLUE}$(version_info golang)${RESET}"
    local _java_info="${BROWN}$(version_info java)${RESET}"
    local _js_info="${HI_YELLOW}$(version_info nodejs)${RESET}"
    local _deno_info="${GREEN}$(version_info deno)${RESET}"
    local _lua_info="${DEEP_PURPLE}$(version_info lua)${RESET}"
    local _python_info="${HI_BLUE}$(version_info python)${RESET}"
    local _ruby_info="${RED}$(version_info ruby)${RESET}"
    local _rust_info="${LIGHT_BROWN}$(version_info rust)${RESET}"

    echo "${_ruby_info}${_rust_info}${_elixir_info}${_erlang_info}${_java_info}${_clojure_info}${_lua_info}${_js_info}${_deno_info}${_python_info}${_go_info}"
  else
    echo ""
  fi
}

version_info() {
  local language_name=$1

  if local version_from_mise=$(mise current $language_name 2>/dev/null) && [[ -n $version_from_mise ]]; then
    version_info_tag $language_name $version_from_mise
  elif local version_from_tool_versions=$(grep "$language_name" "$PWD/.tool-versions" &> /dev/null | cut -d' ' -f2) && [[ -n $version_from_tool_versions ]]; then
    version_info_tag $language_name $version_from_tool_versions
  elif local version_from_language_version=$(grep ".*" ".$language_name-version" 2> /dev/null) && [[ -n $version_from_language_version ]]; then
    version_info_tag $language_name $version_from_language_version
  else
    echo ""
  fi
}

version_info_tag() {
  echo "[$1:$2]"
}
