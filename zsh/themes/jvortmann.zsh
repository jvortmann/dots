# vim: ft=zsh

# Set jvortmann theme if no theme selected
if [ -z "$ZSH_THEME" ]; then
  export ZSH_THEME=jvortmann
fi

elapsed_info() {
  if type gdate > /dev/null; then
    echo "(${LAST_COMMAND_TIME}ms)"
  fi
}

language_info() {
  if declare -f version_info > /dev/null; then
    local _clojure_info="${ORANGE}$(version_info clojure)${RESET}"
    local _elixir_info="${PURPLE}$(version_info elixir)${RESET}"
    local _erlang_info="${MAGENTA}$(version_info erlang)${RESET}"
    local _go_info="${LIGHT_BLUE}$(version_info golang)${RESET}"
    local _java_info="${BROWN}$(version_info java)${RESET}"
    local _js_info="${HI_YELLOW}$(version_info nodejs)${RESET}"
    local _python_info="${HI_BLUE}$(version_info python)${RESET}"
    local _ruby_info="${RED}$(version_info ruby)${RESET}"
    local _rust_info="${LIGHT_BROWN}$(version_info rust)${RESET}"

    echo "${_ruby_info}${_rust_info}${_elixir_info}${_erlang_info}${_java_info}${_clojure_info}${_js_info}${_python_info}${_go_info}"
  else
    echo ""
  fi
}

update_prompt() {
  # left prompt
  _user_and_host="${BLUE}%n@%m${RESET}"
  _cwd="${GREEN}%1~${RESET}"
  
  # display exitcode on the right when >0
  _return_code="%(0?..${RED}%?↵${RESET})"

  PROMPT='${_user_and_host} ${_cwd} $(git_prompt_string) ∴ ${RESET}'
  RPROMPT='$(language_info)$(elapsed_info)$_return_code'
}
update_prompt
