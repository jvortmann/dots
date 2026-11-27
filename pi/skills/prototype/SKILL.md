---
name: prototype
description: "A throwaway that the user starts with /skill:prototype. It answers one named design question fast, such as whether a state flow feels right or which layout works. The outcome is the questions asked and the decisions made. The code is thrown away."
disable-model-invocation: true
---

# Prototype

A prototype is a throwaway. Build it fast, see it work, and learn from it.
What you keep is the learning: the questions you asked and the decisions you
made. The code is never an outcome, and it never merges.

## Name the question

Write one question in one sentence before the first line of code. The question
picks the shape:

- **Does this state flow feel right?** Read [LOGIC.md](LOGIC.md).
- **Which layout, or what should this look like?** Read [UI.md](UI.md).

When the question fits neither, or fits both, ask the user. A wrong shape
wastes the whole prototype. The prototype ends when the question has an
answer. Do not add features after that.

## Rules

- **No tests, no TDD.** The code is a throwaway, so skip tests, polish,
  abstractions and error handling that the run does not need. The prototype
  still gets a task before its first edit.
- **Never merged, never shipped.** A LOGIC prototype lives in a scratch folder
  under `/tmp/scratch`, as the scratch rule in AGENTS.md says. A UI prototype
  needs the real route, so it lives on a `prototype/<name>` branch. The user
  creates that branch, and it never merges.
- **State lives in memory.** Persistence is a reason for a prototype only when
  the question is about persistence.
- **Show the full state** after every action or variant switch, so the user
  sees what changed.

## The outcome

When the question has an answer, the main session records the questions and
the decisions in the plan. A decision that is hard to reverse, surprising, and
a real trade-off goes in an ADR, through the `domain-modeling` skill. Say which
option won and why, and what surprised you. When `dev` built the prototype, it
follows this skill up to this section. It reports the questions and the
decisions, and leaves the folder in place so the user can run the prototype.

Then stop. The code you built stays out of the main branch. Build what ships
fresh, under TDD, from the decisions. The main session removes a scratch folder
as the scratch rule in AGENTS.md says.
