---
name: git-commit
description: Load whenever there is a commit message to work on, every time. Who runs the commit makes no difference, and neither do the words of the request. Writing one, revising one, or handing one over all count, as does a finished task that needs its message and a draft that ste-lint or the commit-msg hook rejected. It carries the rule that the user runs every commit, the two checks a draft must pass, and the handover.
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

## The message

Follow the template at `~/.config/git/message`. Read it once in a session,
and not again for each commit. Load the `asd-ste100` skill for the words.

- **Title** — an uppercase first letter, the imperative mood, 50 characters
  or less, and no period. The hook rejects a title past 72.
- **Body** — why the change exists, and what changes for a user or for the
  system. The diff shows how, so do not restate it. One paragraph of about
  five sentences, wrapped at 72. A second one only when the first cannot hold
  it.
- **No body when the title says enough.** That is the usual case for a
  config, a dependency and a tooling change.
- **No bullets by default.** A list needs three or more independent facts.
  Never one bullet for each file, each function or each step.
- **Name a mechanism only when it surprises.** Why the obvious approach
  failed, or a constraint the reader cannot see. When you cannot name the
  surprise, leave it out.
- **Change-type** — one value from the template, and the most specific one.
  A new capability is `feature`. A restructure that keeps the behavior is
  `refactor`. A defect is `fix`. Build and CI are `ci`, a dependency bump is
  `deps`, and a config file is `config`. The rest are `docs`, `test` and
  `style`. `chore` is the last resort.
- **Copy-paste ready** — no heading for the title or the body.

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

Every reply that works on a message prints the final text in a fenced block,
every time. The clipboard is not the handover, because nobody can read it. A
reply that says the message is ready, and does not show it, delivered nothing.

- Print the text that passed both checks, and never an earlier draft.
- Put the message alone inside the block, with no comment of yours in it, so
  it copies clean.
- Copy the same text with `pbcopy < "$M"`, then delete the file.
- Name the files the commit touches, and stop there.
- When the change needs more than one commit, give a message for each and say
  which one sits on the clipboard. Only one can.
- When a file carries unrelated work as well, say so, and name `git add -p`.
- When the spelling check rejects a tool name, a flag or an identifier, keep
  the word and name it in the reply. The user adds it with `zg`. Rewording a
  message to please a dictionary trades the precise name for a vague one.

## The trailers the hook adds

A branch named after a work item gets a `Work-item-id` trailer from
`prepare-commit-msg`. Do not write that trailer by hand into a drafted
message, because the hook adds it at commit time.

Use only the trailer keys the template carries, with the values and the shape
it shows. `Work-item-id` comes before `Change-type`.
