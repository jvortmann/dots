---
name: create-pr
description: "Load whenever a pull request is about to be created, or its title or body drafted, every time. The words of the request make no difference, and neither does a PR template in the repository. Load it before the first word of the draft. It carries the order of precedence over project PR rules, how to match the voice of the user, what a reviewer needs to read, and the steps to open a draft PR."
---

# Create a PR

This skill sets voice, perspective and detail. It sets no hard format. A
project that needs a format keeps it in its own file.

## Project guidelines first

Look for `.pi/pr-guidelines.md` at the root of the repository.

- When it exists, read all of it. Its format, title, trailers, links and
  extra texts win over this skill, over the repository PR template, and over
  PR rules in a project `AGENTS.md` or `CLAUDE.md`.
- Without it, follow the repository PR template for the format when there is
  one. Follow this skill for everything else.

## Voice

Write like the user. Read two or three of the recent PRs of the user in this
repository, with `gh pr list --author @me --state merged --limit 3` and then
`gh pr view <n>`. Catch the tone, the length and how they open. Take the
voice only, never the content.

Skip this where the user has no PRs, such as a public repository of someone
else.

## Perspective

Write for a reviewer who has not opened the code. Readers outside the team
review the PR too. A text that only its author can decode sends them back
with questions.

- Say what changed for users or the system, and why.
- Give the behavior before the mechanism. Say what the system did wrong, or
  what it does now, then the cause.
- A bold lead names the behavior, never the internal.

```md
Cryptic: **The retry match no longer reads stack frames.** The client builds
each error in `socket_pool.js`, so `socket` matched every error.

Clear: **A failed query no longer retries when the error cannot go away.** The
retry check searched the whole error text for words such as `socket`. Every
ClickHouse error names `socket_pool.js` in its stack, so every error looked
worth a retry.
```

## Detail

- Never list the files or the tests, and never narrate the diff.
- Name a function, a file or an error only when the sentence says what it
  does and the reader needs the name to find the change.
- Keep cause and effect in one place. A reader must not join three sentences
  to learn why something failed.
- Add context only for what the diff cannot show. That is a decision that
  could have gone the other way, state outside the diff, or something left
  out on purpose.
- Keep the text as small as the change allows.
- Add a test plan only when the change is complex enough to need one.

## Steps

1. Inspect the branch, its diff against the default branch, and its commits.
2. Read the project guidelines, when they exist.
3. Hand the title, the body and any other text the guidelines ask for to the
   `editor` agent. Give it the intent and the commit range. When you are the
   editor, draft them yourself.
4. Push with `git push`, only when needed.
5. Create the PR with `gh pr create --draft`.
6. Post any extra text the guidelines ask for.
7. Return the URL, the title and the body.

The prohibitions in `~/.config/pi/AGENTS.md` hold. Never commit, amend or
force push to make a PR.
