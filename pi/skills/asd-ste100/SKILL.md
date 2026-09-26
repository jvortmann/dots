---
name: asd-ste100
description: Load whenever prose a person reads is about to be written or revised, every time. What the text is and why you write it make no difference. A commit message, a PR body, a readme, a comment in code, a task description, a request to remove AI slop, and a fault that ste-lint reported all count. It carries the ASD-STE100 rules for words and sentences, the faults the checker misses, and how to check a draft.
---

# ASD-STE100

Simplified Technical English is the writing standard for aircraft maintenance
manuals. A mechanic reads a procedure one time and acts on it. The same rules
strip the padding out of text an agent writes.

This skill carries Layer 1 of the standard: the words and the sentences. It
does not set the shape of a chat reply.

## Scope

Apply it to a commit message, a PR body, documentation and a README. A code
comment, a task description and an error message also count.

Leave code, identifiers, command syntax, log output and quoted text alone.
Writing that needs a voice, such as an essay, is also out of scope.

## Rules

- **Short sentences** — aim for 20 words, hard stop at 25. One idea per sentence
- **Active voice** — "the wrapper lost the subcommand" over "the subcommand was lost"
- **Short common words** — `need` over `require`, `make sure` over `ensure`, `use` over `utilize`, `start` over `begin`, `give` over `provide`, `about` over `regarding`, `also` over `additionally`, `so` over `in order to`
- **Simple tenses** — "the calls rewrote every field" over `were rewriting` or `have rewritten`
- **Words in full** — `do not` over `don't`. Two sentences over a `;`
- **American spelling** — `behavior` over `behaviour`, `analyze` over `analyse`
- **Plain description** — `start` over `spin up`, `release` over `roll out`. Drop `robust`, `seamless` and `comprehensive`
- **One name for one thing** — the same word for the same idea throughout

## What the checker misses

`ste-lint` reads words and sentences. These faults pass it, so catch them
yourself.

- Open with the change itself. `This commit` and `This change` say nothing.
- State the fact and stop. `Note that` and `Overall` only announce another sentence.
- Two items beat a triad: `fast and clean`, not `fast, clean and reliable`.
- One claim per sentence. `not only ... but also` packs two into one.
- Backticks mark an identifier. A commit body takes no heading, bold or emoji.

## Rewrite

```
It is important to note that this module leverages a robust caching strategy
in order to facilitate seamless performance improvements.
```

Becomes:

```
This module caches the result, so a later read is faster.
```

```
The subcommand was silently lost by the wrapper and was then sent to the model
as a prompt.
```

Becomes:

```
The wrapper lost the subcommand and sent it to the model as a prompt.
```

The second pair shows the usual gain. Active voice names the actor, and the
sentence gets shorter for free.

## When a rule fights the text

- Passive voice is correct when the actor is unknown or does not matter.
- A past participle that works as an adjective is not passive.
  `the valve is closed` and `the field is required` both pass.
- Keep a code span on one line. A span broken over two lines reads as prose.
- Keep a term of art, a proper name and a quotation as they are.
- A sentence that opens with a lowercase tool name hides the sentence break
  from a checker. The word count then reads double. Open with another word.
- Quote a banned word inside backticks or a code fence. The checker skips both,
  so an example never reports a fault.

## Check

Run `ste-lint <file>`. It reports and never rewrites, because only the author
knows the intent. Read the reason, then revise the text yourself.

It reads Markdown, plain text and the comments in a source file. It cannot
judge whether the text says the right thing, so read the result once yourself.
