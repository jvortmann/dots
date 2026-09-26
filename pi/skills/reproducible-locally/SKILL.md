---
name: reproducible-locally
description: Load whenever a change is about to be called done, working or verified, every time. That covers the end of a task, the report of an agent, and any claim that a fix, a feature or a config change works. It carries what counts as proof and the one outcome a report states.
---

# Reproducible locally

A change is complete when its changed behavior has proof that anybody can
run again. Run the proof locally when you can. Run it where the behavior lives
when you must, such as a deployed environment or a real terminal.

## What counts as proof

Exercise the changed behavior and assert a result that a person outside the
code can see. That is a response, stored state, an event, printed output, or
a file on disk.

- A green build proves the build, and nothing more.
- A passing suite proves the scenarios it runs. Say which scenario covers the
  change. A suite with no test for the change proves nothing about it.
- Clicking through an app, reading a dashboard, or reading the code back is
  not proof.
- Reading a setting back after you wrote it proves the write, not the effect.
  Check the effect.

Devise the proof for each change. There is no standing recipe, because each
change fails in its own way.

## Test where the change runs

Find every place that runs the changed code before you choose the proof, and
cover the ones that differ. A check in your own shell can pass while the same
code fails elsewhere. Look at a run without a terminal, inside tmux, in a
preview, in CI, and in a worktree.

## Report one outcome

- **verified**: the scenario, the command you ran, what it asserts, and the
  output it printed.
- **not verified**: what blocked the proof, and the smallest change that
  would make proof possible.

Never report a third outcome such as "should work" or "looks right". A claim
without output behind it is not verified.
