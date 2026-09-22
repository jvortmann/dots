---
name: documentation
description: Load whenever prose for a reader is about to be written, changed or reviewed, every time. The name of the file makes no difference, and neither does the reason. A readme, a plan, a note, a plain text file, a comment in code and a description in a task all count. Load it before the first word, because the first decision is whether the text should exist at all. It carries that decision and the budget that holds the text short.
---

# Documentation and comments

A document and a comment answer the same question: does this text earn its
place? Most do not. Write the ones that do, and keep them short.

## Process

1. **Decide the text earns its place.** A doc earns it with a non-obvious design, a
   flow or contract others must follow, or a gotcha worth recording. When the
   code and the tests already explain the change, stop here. Never create a
   doc to have one.
2. **Read the whole file** before you add to it.
3. **Write to the budget** below.
4. **Delete what your change made obsolete.**

## A document

- **Budget the finished file, not the diff** — what counts is the file that
  exists *after* your edit. How much you added counts for nothing. A doc for
  one component, hook, page or module fits on one screen, about 80 lines. Past
  ~150 it needs a stated reason, and a subsystem-wide doc past ~200 does too.
  An addition that breaks the budget means cutting or rewriting something
  else. Appending is not an option.
- **Revise, never append** — across a series of changes the correct edit
  usually rewrites a paragraph instead of bolting on a section. Several
  defensible additions make one indefensible document.
- **Match the document in front of you** — follow its existing headings, its
  prose against table style, and its level of detail. Material that does not
  fit belongs in a different document.
- **Place it close to the code it describes** — a service or module `docs`
  folder, or a directory-level doc, and not only a top-level file.
- **Keep it high-level and audience-neutral** — useful to a person and to an
  agent. Never a CLAUDE.md or AGENTS.md artifact, because those are
  agent-instruction files and not the documentation.

## A comment

- **Only what the code cannot say** — a comment earns its place when it
  records *why*. That is a non-obvious behavior, a gotcha, or the reason you
  rejected the obvious approach. Delete anything that restates the signature
  or narrates the next line.
- **Short by default** — one or two lines inline. A doc block past about six
  lines needs a reason to exist. When it takes a paragraph, the name or the
  code is usually what needs the fix.
- **Match the file** — follow the surrounding style instead of importing a
  different convention. That covers doc blocks against line comments, and
  whether the file comments its helpers at all.
- **Keep them true** — a comment that outlives the code it described is worse
  than none. Re-read the comments in every hunk you touch.

## One home per fact

If a comment beside the code already says it, the doc must not repeat it. The
same holds in reverse. Duplication makes you keep one reasoning true in two
places, and it rots in the one nobody re-reads.

## Smell checks

- A doc longer than the code it explains is wrong. A genuinely complex system
  earns a long-form architecture doc, with its coordinates tables, diagrams
  and glossaries. Nothing else does.
- A diff that is more than a third comment needs tightening before you present
  it. "Only for complex logic" is self-judged and always says yes. The share
  is not.
