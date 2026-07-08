# vim: ft=zsh

# Set jvortmann theme if no theme selected
if [ -z "$ZSH_THEME" ]; then
  export ZSH_THEME=jvortmann
fi

elapsed_info() {
  if type gdate > /dev/null; then
    if [ $LAST_COMMAND_TIME -lt 1000 ]; then
      printf "(%dms)" $LAST_COMMAND_TIME
    elif [ $LAST_COMMAND_TIME -lt 60000 ]; then
      printf "(%.2fs)" $(($LAST_COMMAND_TIME/1000.))
    elif [ $LAST_COMMAND_TIME -lt 360000 ]; then
      printf "(%.2fm)" $(($LAST_COMMAND_TIME/60000.))
    fi
  fi
}

update_prompt() {
  # left prompt
  _user_and_host="${BLUE}%n@%m${RESET}"

  # display exitcode on the right when >0
  _return_code="%(0?..${RED}%?↵${RESET})"

  # cwd_prompt_string must be evaluated on every render (like git_prompt_string),
  # so it is inlined in PROMPT rather than frozen into a variable here.
  PROMPT='${_user_and_host} ${GREEN}$(cwd_prompt_string)${RESET} $(git_prompt_string) ∴ ${RESET}'
  RPROMPT='$(language_info)$(elapsed_info)$_return_code'
}
update_prompt
