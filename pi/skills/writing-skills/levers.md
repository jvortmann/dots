# Levers for agent text

Reference for `SKILL.md`. Read it when you prune agent text or the rules in
`SKILL.md` do not settle a choice.

## Leading words

A leading word is a short concept the model already knows, such as
_lesson_, _tracer bullet_ or _red_. Repeat it as a token, never as a
sentence. Each use calls up the whole method behind it, in few tokens.

- Look for a triad spelled out at three sites, or a pointer that spends a
  sentence on one idea. Replace each with one word. "A loop that is fast,
  deterministic and cheap" becomes a _tight_ loop.
- Choose a word the model already knows. A word you invent has no meaning
  until you define it, and the definition costs tokens.
- Use the same word in your prompts, your docs and your code. The agent then
  links the word to the material and reaches it more reliably.
- A weak word changes nothing, because the agent does that by default. Pick
  a stronger one, such as _relentless_ for _thorough_.

## The environment is the source of truth

A script list, a config file, the folder layout and `--help` output are a
source of truth. A line in a skill that copies one of them is a cache. It
goes stale.

Keep in the skill only what the agent cannot find by looking. That means an
unwritten convention, the reason for a choice, or a trap that no config
shows. Leave a fact that one file or one command gives to that file or
command.

## Context load and cognitive load

Each text you add spends one of two budgets.

- **Context load** is the cost of text that sits in the window on every turn.
  A description and an AGENTS.md line both count, fired or not.
- **Cognitive load** is the cost for the user, who must remember that a text
  exists and when to use it. Spend it where the user's judgment matters.
  Remove it where it does not.

A text behind a pointer escapes context load, and costs the pointer line. A
text with no pointer costs only cognitive load.

## Sediment

Sediment is the lines left from old fixes. Each one was true once. Nobody
removes it, because adding feels safe and removing feels risky. In time the
live rules lie under stale layers.

When you prune, hunt sediment first. For each line, ask whether it still
bears on what the text does. Delete a line that describes a behavior that
changed. Delete the whole sentence of a no-op, and do not trim its words.

## A complete completion criterion

`SKILL.md` says that a criterion must be checkable. It must also be
complete: it demands all of the work. "List every changed model" forces more
legwork than "write a change list". The same holds for flat reference.
"Apply every rule" sets a bar with no steps.

When the end stays vague after you sharpen it, hide the later steps. Do it
only across a real boundary, such as a hand-off to a subagent.
