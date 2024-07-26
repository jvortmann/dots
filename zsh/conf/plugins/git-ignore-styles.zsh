# Show Git branch/tag, or name-rev if on detached head
git-ignore-styles() {
  cat <(git rev-list $1 --grep='Change-type: style' --no-commit-header --format='%H # %s' --reverse) <(cat .git-blame-ignore-revs) | sort | uniq > .git-blame-ignore-revs
}
