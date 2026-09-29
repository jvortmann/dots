---
name: plan
description: Load whenever an implementation plan is about to be written, revised or checked, every time. That covers a request to plan a change, the Plan agent, and a plan that a later task or another agent will build from. It carries the self-containment test, the shape of a plan, how to split the work into pull requests and steps, and how the plan records progress.
---

# Plan

Research the code, then write a plan that another agent can build from. A plan
changes no source code.

## The self-containment test

A fresh agent reads the plan and nothing else. It never sees the conversation
that produced it. Ask of every plan: could that agent build the right thing
from the plan alone?

So the plan carries the constraints, the decisions already made and why, and
what the research found. It does not need every file path. It needs enough
that a competent agent finds the rest and chooses well.

## Research first

- Read the documentation of the repository for its conventions.
- Read the code the change touches, the code around it, and the tests.
- Look for the same problem solved elsewhere in the repository.
- Read recent history on those files, for how they got this way.

## Where the plan lives

Follow the convention of the repository you work in. Look before you write: a
folder for plans or records, a template, and the names of earlier plans. When
you find a template, use it, and it wins over the shape below. When the
repository has no convention, give the plan in the conversation and ask where
it belongs. Never invent a location.

## The shape

Every plan opens with its metadata, so a reader sees its state at a glance:

```md
# <work item id>: <title>

- **Created**: <date>
- **Started**: <date, or "not yet">
- **Last updated**: <date>
- **Status**: <exactly one of: Planning, In progress, Done>
- **Current focus**: <one line on what happens now>
- **Source**: <link to the ticket or issue, or "none">
- **Related**: <linked work with its relation, or "none">
- **Branch**: <branch, or "not yet">
```

Keep the status line to one word. The detail goes in the current focus.

Then the body, in the minimal shape by default:

- Goal
- What to change, and why
- Out of scope, naming the neighboring work left out on purpose
- The pull requests and their steps
- The skills to use, each with one line on when it applies
- Done when

Use the full shape for an architectural change, a complex feature, or a new
project. It adds the approach with the alternatives you rejected, and what else
the change affects. It also adds the risks, with a mitigation for each.

## Pull requests and steps

One pull request is enough for most work. Split it when one review would be
too large, or when parts can ship apart. Each pull request is a complete slice
that can ship alone, and the order says which comes first.

Each pull request holds steps. Each step becomes one task, and each task
becomes one commit.

- Name a step by its outcome, what is true when it ends. Write "Expired
  tokens get a 401", not "Update the auth middleware".
- Cut by behavior, not by file. A step holds its tests and its code together.
  A map from an exploring agent shows the code, and it is never the shape of
  the steps.
- Give each step the check that proves it.
- Say what a step does, and never paste its code. The code comes when the
  step runs.
- Make the last step a review of the documentation near the changed code.

Split the steps by kind, because each step is one commit:

- A formatting or style change is its own step, before the real change.
- A preparatory refactor is its own step, before the feature it makes easy.
  The `refactoring` skill tells it apart from a refactor inside a cycle.
- The tests of a feature stay in the step of that feature.
- Tests for behavior that already exists are a step of their own.
- Order the steps so that each commit passes the tests and the build alone.

## Record progress

The plan is also the record of the work. Keep two lists at its end:

- **Steps**, a checkbox for each step, marked with the date it finished.
- **Progress log**, a row for each task with the date, what happened, and the
  outcome.

After each task, mark its step, add its row, and update the status, the current
focus and the last-updated date. Record what changed from the plan and why. A
plan that still describes the first idea after five steps misleads the agent
that reads it next.
