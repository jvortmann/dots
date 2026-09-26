---
name: retro
description: Load whenever a piece of work is reviewed to improve the agent setup, every time. That covers a request for a retro or a retrospective, a question on what could have gone better, a request to turn a lesson into a skill, and the end of a long task that hit corrections or dead ends. It carries where the evidence lives, what counts as a finding, and how to propose a change without applying it.
---

# Retro

Review a piece of work, and turn what went wrong into changes to the agent
setup. A change can go in a skill, a prompt, an agent file, or AGENTS.md.
Analyze first. Change nothing until the user picks.

## Read the evidence

The evidence is what happened, not what you remember. Read the sessions of the
work with the `pi-sessions` skill.

- Start with the subagent sessions. A subagent works where nobody watches, so
  its struggles appear in its session and never in its report.
- Then read the main session for the user's side.
- Skim for trouble, and read closely only where you find it.

## What counts as a finding

- A correction from the user, such as "no, do X" or "I told you already".
- A tool call that failed, a retry, or a dead end the agent worked around.
- A skill that the task needed and the agent did not load, or a skill that
  loaded and lacked a detail.
- A fact the agent learned late, which a skill can give it at the start.
- A workflow the agent built from nothing, which a skill can carry.
- A report that claimed more than its session shows.

## Report the findings

Order them by the time or the corrections each one costs. For each one, give:

- **Evidence**: the session, and what happened there, quoted or counted.
- **Change**: the edit, in a sentence or two.
- **Target**: the file it goes in.

Sort each finding into one group:

- **A new skill** for a workflow that repeats. Give its name and what it holds.
- **A change to a skill**, with the skill and the detail to add.
- **A change to a rule, a prompt or an agent**, with the file.
- **Not worth encoding**, for a one-off mistake. Name these, so one incident
  does not become a permanent rule.

A single failure is not a skill. Prefer a change that covers the pattern.

## Apply only what the user picks

Present the findings and stop. Make each change the user picks as its own
task, and load the `writing-skills` skill for it. Never remove a guardrail on
your own finding. Name it, and let the user decide.
