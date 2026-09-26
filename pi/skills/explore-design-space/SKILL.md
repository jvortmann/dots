---
name: explore-design-space
description: Load whenever a plan, a design or an idea needs its open decisions settled before work starts, every time. That covers a request to grill me or to stress-test a plan, a design with choices nobody made yet, and a plan whose questions keep coming back. It carries how to find the decisions, which to ask first, and when the exploration ends.
---

# Explore the design space

Question the user until you both hold the same picture of the design. Nothing
in it may rest on a guess. Change nothing while you explore.

## The tree

Map the design as a tree. Each decision branches into the decisions that
depend on it. The frontier is every open decision whose parent decisions are
already settled. You can ask it now, without a guess at an answer you have
not heard.

## Facts are yours, decisions are the user's

- **A fact** comes from the code, the tools or the files. Find it yourself, and
  never ask the user for it. A search that is still running holds back only
  the questions that depend on it.
- **A decision** is a choice the user makes. Put it to the user, and wait.

## Ask in rounds

Ask the whole frontier in one round, with the question tool when you have one.

- Give each question your recommended answer, marked as recommended, and say
  why in one line.
- Leave out a question whose answer depends on another question in the same
  round. It goes in a later round.
- After each round, mark what the answers settled, find the new frontier, and
  ask again.

## When it ends

The exploration ends when the frontier is empty: every branch visited, and
nothing left assumed without a word. Sum up the decisions in a short list, and
ask the user to confirm it. Act only after the user confirms. When the design
turns into a plan, load the `plan` skill.
