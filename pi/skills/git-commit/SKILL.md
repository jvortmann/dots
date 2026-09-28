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
  Read them right before you draft, and write from that diff. Never write from
  memory of your edits, because the user can commit or stage part of them in
  the meantime.
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
  A new capability is `feature`, and a defect is `fix`. A `refactor` changes
  structure and organization only, and no behavior changes at all. The
  `refactoring` skill holds the definition. Build and
  CI are `ci`, a dependency bump is `deps`, and a config file is `config`. The
  rest are `docs`, `test` and `style`. `chore` is the last resort.
- **A file an agent reads as instruction is code, not documentation.** Pick
  the type by what changes in its behavior. A new behavior is `feature`, a
  broken one is `fix`, and one that holds is `refactor`. `docs` is right
  only when the text explains and nothing acts on it.
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
- Copy the same text with `pbcopy < "$M"`, then delete the file. Copy only
  in the session the user reads directly. A subagent leaves the clipboard
  alone and puts the message in its report, because the clipboard belongs to
  the user.
- When a subagent reports a message, the session the user reads does the
  handover. Print it, run both checks again on that exact text, and copy it.
  A report cannot prove its checks ran, and a hand-off can drop a newline.
- Name the files the commit touches, and stop there.
- When the change needs more than one commit, give a message for each and say
  which one sits on the clipboard. Only one can.
- When a file carries unrelated work as well, say so, and name `git add -p`.
- When the spelling check rejects a tool name, a flag or an identifier, keep
  the word and name it in the reply. The user adds it with `zg`. Rewording a
  message to please a dictionary trades the precise name for a vague one.

## Trailers

Use only the trailer keys the template carries, with the values and the shape
it shows. Keep them in this order: `Work-item-id`, `Change-type`, `Refactoring`,
`See-also`, then the advisory ids.

- **`Work-item-id`** comes from `prepare-commit-msg` on a branch named after a
  work item. Do not write it by hand, because the hook adds it at commit time.
- **`Refactoring`** goes on a `refactor` commit, and names the catalog id of
  each refactoring it applies, such as `extractFunction`. Write one line for
  each. The ids are in the `refactoring` skill.
- **`See-also`** points at an outside reference the change adapts or depends
  on: a website, a commit hash, or a `file:line`. Write one line for each
  reference.
- **`GHSA-id`, `CVE-id` and `CWE-id`** go on a change that fixes a security
  issue. GHSA and CVE name the advisory, and CWE names the class of weakness,
  such as `CWE-502`. Write one line for each id, as many as the fix clears.
  They do not come in sets, because an advisory can have a GHSA id and no
  CVE id.
  The body names the vulnerable range, the patched version, and how the
  package reaches the tree.
