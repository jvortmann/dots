# vim: ft=zsh

# Set jvortmann theme if no theme selected
if [ -z "$ZSH_THEME" ]; then
  export ZSH_THEME=jvortmann
fi

# Enable dynamic prompt
setopt prompt_subst

local _user_and_host="${BLUE}%n@%m${RESET}"
local _cwd="${GREEN}%1~${RESET}"
local _ruby_info="${RED}$(rbenv_prompt_info)${RESET}"

declare -f rbenv_prompt_info > /dev/null
if [ $? -ne 0 ]; then
  rbenv_prompt_info() { }
fi

PROMPT='${_user_and_host} ${_cwd}${_ruby_info}$(git_prompt_string) ∴ ${RESET}'

# display exitcode on the right when >0
return_code="%(?..${RED}%? ↵${RESET})"

if type gdate > /dev/null; then
  RPROMPT='(${LAST_COMMAND_TIME}ms) ${return_code}${RESET}'
fi
