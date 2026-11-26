---
name: writing-skills
description: Load whenever a skill, an agent file or a prompt template is about to be written, revised, reviewed or pruned, every time. That covers a new skill, a change to a description, a skill that did not load or misfired, and a choice of where a rule lives. It carries how to write a skill that fires the same way every run, the traps that silently break one, and how to prove that one loads.
---

# Writing skills

A skill makes the agent follow the same process every run. It does not make
the output identical. Every rule below serves that.

## The description decides everything

The agent reads only the description before it chooses to load the skill.

- **State a condition, not trigger words.** "Load whenever there is a commit
  message to work on" fires on "give me a message". A list of trigger phrases
  misses every phrase not on it.
- **Name who and what does not matter.** "Who runs the commit makes no
  difference" closes an escape the agent would otherwise take.
- **End with what the skill carries**, so the agent knows what it loses by
  not loading it.
- **Never put `: ` in an unquoted description.** YAML fails to parse it, and
  pi drops the skill without an error. After any change to the frontmatter,
  run the pi loader and check that the skill is on the list.

## State the intent

Say what to achieve and why. Leave the mechanics to the agent when several
ways work. "Cherry-pick the commit and keep its intent through a conflict"
beats three numbered git commands.

Be exact only where a different way breaks something, such as a command with
flags that must not change. Most of a skill is intent.

## What earns a line

- The intent, and the limits on it.
- Knowledge the agent does not have: syntax, the quirks of a tool, a format.
- Hard rules, stated as rules. Pair each prohibition with what to do instead.
- What the output looks like.
- A trap that is not obvious, with the fix.

Delete a line the agent already follows without it. Test each sentence: does
it change what the agent does? Keep one home for each fact, and prune a line
that no longer applies.

A guardrail is not a duplicate. A NEVER list can say again what the MUST list
says. That repeated prohibition holds the agent to the process, so keep it on
purpose. One home applies to facts and methods. In a
review, name a guardrail you think is redundant, and remove it only when the
user agrees.

## Keep it short

Past about 80 lines of prose, ask whether each line earns its place. Move
reference that only some runs need into a file beside SKILL.md. Give it a
pointer that says when to read it. A table or an example that the reader needs
does not count against the prose.

End each step on a condition the agent can check. A vague end lets it stop
early. A late step with no output, such as a verification, is the one it
drops.

## Where a rule lives

- **A rule that must always hold goes in AGENTS.md**, such as a prohibition
  or who runs a commit. A method goes in a skill.
- **AGENTS.md orders the load, and the skill holds the method.** A method
  written out in both places competes, and the agent follows whichever copy
  it read.
- **Two files that defer to each other leave the rule nowhere.** Name one
  owner for each fact.
- **A step that must fire on a moment belongs where that moment is.** An
  update after each task goes in the task loop, not in a skill with a trigger.

## Skills in an agent

- `skills:` in an agent file puts the whole text in its system prompt, so the
  agent cannot skip it. It also stops discovery of every other skill.
- `prompt_mode: replace` drops AGENTS.md. An agent that writes needs `append`,
  or its own copy of the prohibitions.
- The agent file outranks its caller for `max_turns`, `model` and `thinking`.
  A value the caller passes has no effect when the file sets one.

## Prove that it fires

A skill that loads when you name it proves only that the file exists.

1. Run the pi loader, and check that the skill is on the list.
2. Give an agent a real task that matches the description, without naming the
   skill.
3. Read that agent's session file with the `pi-sessions` skill, and find the
   read of the SKILL.md. A skill that the agent did not read did not fire.

A subagent copies the system prompt of its parent as it stood when that
session started. So a change to AGENTS.md or to a skill description reaches a
subagent only after `/reload` or a new session. Probe such a change from a
fresh session. When a skill loads, pi reads its body from disk, so a change there
applies at once.
