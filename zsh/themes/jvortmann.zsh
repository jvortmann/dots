# vim: ft=zsh

# Set jvortmann theme if no theme selected
if [ -z "$ZSH_THEME" ]; then
  export ZSH_THEME=jvortmann
fi

if ! declare -f ruby_version_info > /dev/null
then
  ruby_version_info() { }
fi

if ! declare -f python_version_info > /dev/null
then
  python_version_info() { }
fi

update_prompt() {
  _user_and_host="${BLUE}%n@%m${RESET}"
  _cwd="${GREEN}%1~${RESET}"
  _ruby_info="${RED}$(ruby_version_info)${RESET}"
  _python_info="${BLUE}$(python_version_info)${RESET}"
  _elixir_info="${MAGENTA}$(version_info elixir)${RESET}"

  # display exitcode on the right when >0
  _return_code=" %(0?..${RED}%? ↵${RESET})"

  PROMPT='${_user_and_host} ${_cwd} $(git_prompt_string) ∴ ${RESET}'

  if type gdate > /dev/null; then
    RPROMPT='${_ruby_info}${_elixir_info}${_python_info}(${LAST_COMMAND_TIME}ms)${_return_code}${RESET}'
  else
    RPROMPT='${_ruby_info}${_elixir_info}${_python_info}${return_code}${RESET}'
  fi
}

update_prompt
