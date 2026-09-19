---
name: git-commit
description: Draft a commit message, check it with ste-lint and the commit-msg hook, then copy it to the clipboard. Use when asked to commit, on the word `commit`, and when a finished task needs its message.
---

# Git commit

The user runs every commit. Never run `git commit` or `git commit --amend`
unless the user says the exact phrase "you can commit". Every other mention
of committing means one thing: draft the message, check it, show it, copy it,
and stop.

## Read the change first

- `git status --short` and `git diff --cached` for what the commit carries.
- `git log -5 --format='%B'` for the voice of the recent history.
- Never prepare a commit that holds unrelated changes, or one with a failing
  test.

The message rules live in `~/.config/pi/AGENTS.md` and in the template at
`~/.config/git/message`. Load the `asd-ste100` skill for the words.

## Check the draft

Write the draft to a temporary file and run both checks against it.

```sh
M=$(mktemp -t msg).txt
cat > "$M" <<'EOF'
Title here

Body here.

Change-type: fix
EOF
ste-lint "$M"
bash ~/.config/git/hooks/commit-msg "$M"
```

Read what they report, revise the text, and run them again. Neither tool
rewrites prose, because only the author knows the intent. The user reads a
corrected message, never a warning.

## Hand it over

- Copy the corrected message with `pbcopy < "$M"`, then delete the file.
- Show the same message in the reply, inside a fenced block, so the reader
  sees what the clipboard holds.
- Name the files the commit touches, and stop there.
- When the change needs more than one commit, give a message for each and say
  which one sits on the clipboard. Only one can.
- When a file carries unrelated work as well, say so, and name `git add -p`.

## The trailers the hook adds

A branch named after a work item gets a `Work-item-id` trailer from
`prepare-commit-msg`. Do not write that trailer by hand into a drafted
message, because the hook adds it at commit time.
