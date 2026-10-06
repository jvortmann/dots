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
_GIT_PROMPT_UNTRACKED="%{$BLUE%}•%{$RESET%}"
_GIT_PROMPT_MODIFIED="%{$YELLOW%}•%{$RESET%}"
_GIT_PROMPT_DELETED="%{$RED%}•%{$RESET%}"
_GIT_PROMPT_STAGED="%{$GREEN%}•%{$RESET%}"

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
  # Match status lines with zsh patterns, not grep. In the prompt, grep runs
  # greprip through a mise shim, which is slow and can print mise errors.
  local -a STATUS_LINES=("${(@f)$(git status --porcelain)}")

  if [ "$NUM_AHEAD" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${_GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
  fi

  if [ "$NUM_BEHIND" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${_GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
  fi

  if (( ${#${(M)STATUS_LINES:#UU*}} )); then
    GIT_STATE=$GIT_STATE$_GIT_PROMPT_MERGING
  fi

  if (( ${#${(M)STATUS_LINES:#?D*}} )); then
    GIT_STATE=$GIT_STATE$_GIT_PROMPT_DELETED
  fi

  if (( ${#${(M)STATUS_LINES:#\?\?*}} )); then
    GIT_STATE=$GIT_STATE$_GIT_PROMPT_UNTRACKED
  fi

  if (( ${#${(M)STATUS_LINES:#?[TMRC]*}} )); then
    GIT_STATE=$GIT_STATE$_GIT_PROMPT_MODIFIED
  fi

  if (( ${#${(M)STATUS_LINES:#[ATMRCD]?*}} )); then
    GIT_STATE=$GIT_STATE$_GIT_PROMPT_STAGED
  fi

  if [[ -n $GIT_STATE ]]; then
    echo "$_GIT_PROMPT_PREFIX$GIT_STATE$_GIT_PROMPT_SUFFIX"
  fi
}

# Emoji shown in place of the path when inside a linked git worktree, since
# the worktree directory name only duplicates the branch shown in [ ].
_GIT_WORKTREE_SYMBOL="🌱"

# Path segment for the prompt. Inside a *linked* worktree, show the seedling
# plus the main repository's name (the worktree root duplicates the branch
# shown in [ ]); below the worktree root also append the current directory.
# Otherwise fall back to the leaf directory.
# A linked worktree is the one case where --git-dir and --git-common-dir differ.
cwd_prompt_string() {
  local dirs
  dirs=("${(@f)$(git rev-parse --git-dir --git-common-dir --show-prefix 2> /dev/null)}")

  # Resolve to absolute paths: git reports one relative and one absolute in
  # subdirectories, which would otherwise look like a linked worktree.
  local gitdir=${dirs[1]:A} common=${dirs[2]:A}

  if [[ -n $dirs[1] && $gitdir != $common ]]; then
    local repo
    if [[ ${common:t} == .git ]]; then
      repo=${common:h:t}
    else
      repo=${common:t:r}
    fi
    if [[ -n $dirs[3] ]]; then
      echo "$_GIT_WORKTREE_SYMBOL ${repo//\%/%%} %1~"
    else
      echo "$_GIT_WORKTREE_SYMBOL ${repo//\%/%%}"
    fi
  else
    echo "%1~"
  fi
}

# If inside a Git repository, print its branch and state
git_prompt_string() {
  local _GIT_BRANCH="$(git_branch)"
  if [ -n "$_GIT_BRANCH" ]; then
    echo "$_GIT_PROMPT_SYMBOL$_GIT_PROMPT_PREFIX$_GIT_BRANCH$_GIT_PROMPT_SUFFIX$(git_status)"
  fi
}
