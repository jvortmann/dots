# vim: ft=zsh
#
# Adapted from code found at <https://gist.github.com/joshdick/4415470>.

# Modify the colors and symbols in these variables as desired.
_GIT_PROMPT_SYMBOL=""
_GIT_PROMPT_BRANCH="%{$RESET$BOLD%}BRANCH%{$RESET%}"
_GIT_DIRTY_BRANCH="%{$YELLOW$UNDER%}BRANCH%{$RESET%}"
_GIT_PROMPT_PREFIX="%{$RESET%}[%{$RESET%}"
_GIT_PROMPT_SUFFIX="%{$RESET%}]%{$RESET%}"
_GIT_PROMPT_AHEAD="%{$CYAN%}↑NUM%{$RESET%}"
_GIT_PROMPT_BEHIND="%{$RED%}↓NUM%{$RESET%}"
_GIT_PROMPT_MERGING="%{$RED%}Ϟ%{$RESET%}"
_GIT_PROMPT_UNTRACKED="%{$BLUE%}●%{$RESET%}"
_GIT_PROMPT_MODIFIED="%{$YELLOW%}●%{$RESET%}"
_GIT_PROMPT_DELETED="%{$RED%}●%{$RESET%}"
_GIT_PROMPT_STAGED="%{$GREEN%}●%{$RESET%}"

# Show Git branch/tag, or name-rev if on detached head
git_branch() {
  local GIT_BRANCH="$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/' -e 's/(\(.*\))/\1/')"

  if [ -n "$GIT_BRANCH" ]; then
    if [ $GIT_BRANCH -regex-match "no branch|detached" 2> /dev/null ]; then
      echo ${_GIT_DIRTY_BRANCH//BRANCH/$GIT_BRANCH}
    else
      echo ${_GIT_PROMPT_BRANCH//BRANCH/$GIT_BRANCH}
    fi
  fi
}

# Show different symbols as appropriate for various Git repository states
git_status() {
  # Compose this value via multiple conditional appends.
  local GIT_STATE=""

  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  local STATUS="$(git status --porcelain)"

  if [ "$NUM_AHEAD" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${_GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
  fi

  if [ "$NUM_BEHIND" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${_GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
  fi

  if echo $STATUS | grep '^UU' --quiet; then
    GIT_STATE=$GIT_STATE$_GIT_PROMPT_MERGING
  fi

  if echo $STATUS | grep '^D' --quiet; then
    GIT_STATE=$GIT_STATE$_GIT_PROMPT_DELETED
  fi

  if echo $STATUS | grep '^??' --quiet; then
    GIT_STATE=$GIT_STATE$_GIT_PROMPT_UNTRACKED
  fi

  if echo $STATUS | grep '^.[MRC]' --quiet; then
    GIT_STATE=$GIT_STATE$_GIT_PROMPT_MODIFIED
  fi

  if echo $STATUS | grep '^[AMRC].' --quiet; then
    GIT_STATE=$GIT_STATE$_GIT_PROMPT_STAGED
  fi

  if [[ -n $GIT_STATE ]]; then
    echo "$_GIT_PROMPT_PREFIX$GIT_STATE$_GIT_PROMPT_SUFFIX"
  fi
}

# If inside a Git repository, print its branch and state
git_prompt_string() {
  local _GIT_BRANCH="$(git_branch)"
  if [ -n "$_GIT_BRANCH" ]; then
    echo "$_GIT_PROMPT_SYMBOL$_GIT_PROMPT_PREFIX$_GIT_BRANCH$_GIT_PROMPT_SUFFIX$(git_status)"
  fi
}
