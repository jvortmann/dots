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

# If inside a Git repository with a commit, print its branch and state. One
# git call gives the branch, the counts against the upstream and the files.
# Match its lines with zsh patterns, not grep, because a pattern starts no
# new process.
git_prompt_string() {
  local -a lines=("${(@f)$(git status --porcelain=v2 --branch 2> /dev/null)}")
  local head=${${(M)lines:#\# branch.head *}#\# branch.head }
  [[ -z $head || -n ${(M)lines:#\# branch.oid \(initial\)} ]] && return

  local branch=${_GIT_PROMPT_BRANCH//BRANCH/$head}
  if [[ $head == '(detached)' ]]; then
    # Only git branch tells what a detached head is at, such as a tag.
    head=${${(M)${(f)"$(git branch --no-color 2> /dev/null)"}:#\* *}#\* }
    branch=${_GIT_DIRTY_BRANCH//BRANCH/${${head#\(}%\)}}
  fi

  local -a counts=(${=${${(M)lines:#\# branch.ab *}#\# branch.ab }})
  local ahead=${counts[1]#+} behind=${counts[2]#-} state=""
  (( ahead > 0 )) && state+=${_GIT_PROMPT_AHEAD//NUM/$ahead}
  (( behind > 0 )) && state+=${_GIT_PROMPT_BEHIND//NUM/$behind}
  (( ${lines[(I)u UU *]} )) && state+=$_GIT_PROMPT_MERGING
  (( ${lines[(I)[12u] ?D *]} )) && state+=$_GIT_PROMPT_DELETED
  (( ${lines[(I)\? *]} )) && state+=$_GIT_PROMPT_UNTRACKED
  (( ${lines[(I)[12u] ?[TMRC] *]} )) && state+=$_GIT_PROMPT_MODIFIED
  (( ${lines[(I)[12u] [ATMRCD]? *]} )) && state+=$_GIT_PROMPT_STAGED

  local marks=""
  [[ -n $state ]] && marks=$_GIT_PROMPT_PREFIX$state$_GIT_PROMPT_SUFFIX
  echo "$_GIT_PROMPT_SYMBOL$_GIT_PROMPT_PREFIX$branch$_GIT_PROMPT_SUFFIX$marks"
}
