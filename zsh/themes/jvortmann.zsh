# vim: ft=zsh

# Set jvortmann theme if no theme selected
if [ -z "$ZSH_THEME" ]; then
  export ZSH_THEME=jvortmann
fi

update_prompt() {
  # left prompt
  _user_and_host="${BLUE}%n@%m${RESET}"
  _cwd="${GREEN}%1~${RESET}"
  
  # display exitcode on the right when >0
  _return_code="%(0?..${RED}%?↵${RESET})"

  PROMPT='${_user_and_host} ${_cwd} $(git_prompt_string) ∴ ${RESET}'

  _rprompt=""

  if declare -f version_info > /dev/null; then
    _ruby_info="${RED}$(version_info ruby)${RESET}"
    _python_info="${BLUE}$(version_info python)${RESET}"
    _elixir_info="${MAGENTA}$(version_info elixir)${RESET}"
    _rust_info="${ORANGE}$(version_info rust)${RESET}"
    _go_info="${CYAN}$(version_info golang)${RESET}"

    _language_tags="${_ruby_info}${_rust_info}${_elixir_info}${_python_info}${_go_info}"

    _rprompt="$_rprompt$_language_tags"
  fi

  if type gdate > /dev/null; then
    _rprompt="$_rprompt(\${LAST_COMMAND_TIME}ms)"
  fi

  RPROMPT="$_rprompt$_return_code"
}

update_prompt
