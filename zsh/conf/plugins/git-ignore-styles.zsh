# Update .git-blame-ignore-revs file with commits from the branch that have the `Change-type: style` trailer
git-ignore-styles() {
  cat <(git rev-list $1 --grep='Change-type: style' --no-commit-header --format='%H # %s' --reverse) .git-blame-ignore-revs | sort | uniq > .git-blame-ignore-revs.temp && mv .git-blame-ignore-revs{.temp,}
}
