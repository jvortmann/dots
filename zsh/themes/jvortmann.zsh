# vim: ft=zsh

# Set jvortmann theme if no theme selected
if [ -z "$ZSH_THEME" ]; then
  export ZSH_THEME=jvortmann
fi

# Enable dynamic prompt
setopt prompt_subst

if ! declare -f ruby_version_info > /dev/null
then
  ruby_version_info() { }
fi

local _user_and_host="${BLUE}%n@%m${RESET}"
local _cwd="${GREEN}%1~${RESET}"
local _ruby_info="${RED}$(ruby_version_info)${RESET}"

# display exitcode on the right when >0
local _return_code=" %(0?..${RED}%? ↵${RESET})"

PROMPT='${_user_and_host} ${_cwd} $(git_prompt_string) ∴ ${RESET}'

if type gdate > /dev/null; then
  RPROMPT='${_ruby_info}(${LAST_COMMAND_TIME}ms)${_return_code}${RESET}'
else
  RPROMPT='${_ruby_info}${return_code}${RESET}'
fi
