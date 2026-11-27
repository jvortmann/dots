---
name: explore-design-space
description: Load whenever a plan, a design or an idea needs its open decisions settled before work starts, every time. That covers a request to grill me or to stress-test a plan, a design with choices nobody made yet, and a plan whose questions keep coming back. It carries how to find the decisions, which to ask first, and when the exploration ends.
---

# Explore the design space

Question the user until you both hold the same picture of the design. Nothing
in it may rest on a guess. Change nothing in the project while you explore.

## The tree

Map the design as a tree. Each decision branches into the decisions that
depend on it. The frontier is every open decision whose parent decisions are
already settled. You can ask it now, without a guess at an answer you have
not heard.

## Facts are yours, decisions are the user's

- **A fact** comes from the code, the tools or the files. Find it yourself, and
  never ask the user for it. For a source outside the change, hand it to the
  Explore agent. "Research goes to the Explore agent" in AGENTS.md says how.
  A tool behavior still goes to a spike. A search that is still running
  holds back only the questions that depend on it.
- **A decision** is a choice the user makes. Put it to the user, and wait.
- **A tool behavior that nobody tried is a guess, not a fact.** When the
  design rests on one, prove it with a short spike before the user confirms
  the design. A spike is the smallest run that shows the behavior, in a
  scratch folder, with no change to the project.
- **A design that copies an outside system names the system it must match.**
  For example, a command format can follow Claude Code or pi. When the target
  is not clear, it is a decision for the user.

## Ask in rounds

Ask the whole frontier in one round, with the question tool when you have one.

- Give each question your recommended answer, marked as recommended, and say
  why in one line. Word the question so that "yes" accepts that answer.
  Put that option first, as "Ask with the tool" in AGENTS.md says, and label
  it so that "yes" accepts it.
- With the question tool, use a short header, a question worded for "yes",
  and the recommended option first. Put the one-line why in the description
  of that option.
- With no tool, format each question the same way: a number, a short title,
  the body, then the recommended answer on its own line.
- Leave out a question whose answer depends on another question in the same
  round. It goes in a later round.
- After each round, mark what the answers settled, find the new frontier, and
  ask again.
- When a term is new, vague or in conflict with the glossary, or a decision
  may need an ADR, load the `domain-modeling` skill.

## When it ends

The exploration ends when the frontier is empty: every branch visited, and
nothing left assumed without a word. A tool behavior that nobody tried keeps
the exploration open. Sum up the decisions in a short list, and ask the user
to confirm it. Act only after the user confirms. When the design turns into a
plan, load the `plan` skill.
