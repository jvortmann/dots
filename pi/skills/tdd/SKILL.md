---
name: tdd
description: Test-driven development in baby steps. Load it before you write or change any implementation code, every time, whatever the change looks like. It carries the RED and GREEN cycle, the rules that hold the cycle together, a worked example, and the test style. When the work seems to fall outside a cycle, ask the user rather than decide alone.
---

# TDD

Baby steps, for every implementation task. One scenario, one failing test, the
smallest code that passes it.

This skill applies to all code you write or change. It does not ask you to
judge whether the change is big enough, or whether the behavior is new. A rule
that the writer can waive is not a rule. When you believe the work falls
outside a cycle, stop and ask the user. Do not decide alone, and do not skip
the cycle on your own judgment.

## The cycle

For each test scenario in the task:

1. **Write ONE test scenario first** — a single test case, before you create
   or edit any implementation code.
2. **Run the ENTIRE test file** — see it fail (RED). Do not touch the
   implementation until that failure appears.
3. **Write the MINIMUM code** — only what makes this one test pass.
4. **Run the ENTIRE test file** — it passes and nothing else broke (GREEN).
5. **Refactor if needed** — the file stays green.
6. **Repeat** — take the next scenario.

When every scenario passes, draft the commit message and let the user commit.
Load the `git-commit` skill for that part.

## Rules that hold the cycle together

- The first file you create or edit for any behavior is the test.
- One scenario at a time. Never write several tests and then build everything.
- See the test fail before you write the code. A test that never failed proves
  nothing.
- Run the whole test file, never a single test.
- Write the minimum that passes. Leave the rest for the next scenario.
- One task holds its scenarios, its implementation, and one passing commit. A
  separate task for tests and another for implementation splits the cycle in
  half.
- Structure a task by behavior or workflow, never by file or artifact. Output
  from an exploring agent describes the architecture for understanding only.
  It is never the basis for task structure.
- A task can hold several scenarios: the success, the errors, the edges.
- Never commit until every test for the task passes.
- Never make a formatting or style change the user did not ask for.

## A worked example

```
Task: Add flexible updateAudience()

Baby step 1:
  1. Write test: "updates only description"
  2. Run tests -> see it FAIL (RED)
  3. Add the minimum code for the description field
  4. Run tests -> see it PASS (GREEN)

Baby step 2:
  1. Write test: "updates only membershipDurationDays"
  2. Run tests -> see it FAIL (RED)
  3. Add the minimum code for the membershipDurationDays field
  4. Run tests -> see it PASS (GREEN)

Baby step 3:
  1. Write test: "updates multiple fields together"
  2. Run tests -> see it FAIL (RED)
  3. Refactor to handle the combinations
  4. Run tests -> see it PASS (GREEN)

After every scenario passes:
  5. Draft the commit message with the right Change-type, and copy it
  6. The user commits. Never run `git commit` yourself
```

## Test style

- **Describe the behavior, not the function.** A test name that carries a
  function name describes the implementation, and it goes stale with it.
  - Write `accepts valid ISO 8601 timestamp strings`
  - Not `validateTimestamp returns valid for ISO strings`
- **Assert true or false, never truthy or falsy.** A truthy check passes on a
  value you did not intend.
  - Write `t.true(typeof result.error === "string" && result.error.length > 0)`
  - Not `t.truthy(result.error)`
