# vim: ft=zsh
#
# Adapted from code found at <https://gist.github.com/joshdick/4415470>.

setopt prompt_subst
autoload -U colors # Enable colors in prompt

# Modify the colors and symbols in these variables as desired.
_GIT_PROMPT_SYMBOL=""
_GIT_PROMPT_BRANCH="%{$RESET$BOLD%}BRANCH%{$RESET%}"
_GIT_PROMPT_PREFIX="%{$RESET%}[%{$RESET%}"
_GIT_PROMPT_SUFFIX="%{$RESET%}]%{$RESET%}"
_GIT_PROMPT_AHEAD="%{$RED%}↑NUM%{$RESET%}"
_GIT_PROMPT_BEHIND="%{$CYAN%}↓NUM%{$RESET%}"
_GIT_PROMPT_MERGING="%{$RED%}⚡︎%{$RESET%}"
_GIT_PROMPT_UNTRACKED="%{$BLUE%}●%{$RESET%}"
_GIT_PROMPT_MODIFIED="%{$YELLOW%}●%{$RESET%}"
_GIT_PROMPT_STAGED="%{$GREEN%}●%{$RESET%}"

# Show Git branch/tag, or name-rev if on detached head
git_branch() {
  local GIT_SYMBOLIC_REF=$(git symbolic-ref -q HEAD 2> /dev/null)
  local GIT_NAME_REV=$(git name-rev --name-only --no-undefined --always HEAD 2> /dev/null)

  local GIT_BRANCH=$GIT_SYMBOLIC_REF || $GIT_NAME_REV

  if [ -n "$GIT_BRANCH" ]; then
    echo ${_GIT_PROMPT_BRANCH//BRANCH/${GIT_BRANCH#(refs/heads/|tags/)}}
  fi
}

# Show different symbols as appropriate for various Git repository states
git_status() {

  # Compose this value via multiple conditional appends.
  local GIT_STATE=""

  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${_GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
  fi

  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${_GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
  fi

  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    GIT_STATE=$GIT_STATE$_GIT_PROMPT_MERGING
  fi

  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    GIT_STATE=$GIT_STATE$_GIT_PROMPT_UNTRACKED
  fi

  if ! git diff --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$_GIT_PROMPT_MODIFIED
  fi

  if ! git diff --cached --quiet 2> /dev/null; then
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
    echo " $_GIT_PROMPT_SYMBOL$_GIT_PROMPT_PREFIX$_GIT_BRANCH$_GIT_PROMPT_SUFFIX$(git_status)"
  fi
}
