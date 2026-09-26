---
name: tdd
description: Load it before you write or change any implementation code, every time, whatever the change looks like. It carries test-driven development in baby steps, the RED and GREEN cycle, the rules that hold the cycle together, and a worked example, and it loads the testing skill for the test itself. When the work seems to fall outside a cycle, ask the user rather than decide alone.
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
2. **Run the ENTIRE test file** — see it fail (RED), then read the failure.
   Do not touch the implementation until the right failure appears (see
   below).
3. **Write the MINIMUM code** — only what makes this one test pass.
4. **Run the ENTIRE test file** — it passes and nothing else broke (GREEN).
5. **Refactor if needed** — the file stays green.
6. **Repeat** — take the next scenario.

When every scenario passes, draft the commit message and let the user commit.
Load the `git-commit` skill for that part.

## One slice at a time

Never write every test first and then every implementation. Tests written in
bulk test the behavior you imagined, not the behavior you built. Each test
should answer what the last cycle taught you.

```
WRONG, horizontal:
  RED:   test1, test2, test3, test4
  GREEN: impl1, impl2, impl3, impl4

RIGHT, vertical:
  RED -> GREEN: test1 -> impl1
  RED -> GREEN: test2 -> impl2
  RED -> GREEN: test3 -> impl3
```

Check each cycle before the next one:

- [ ] The test describes behavior, not the implementation.
- [ ] It uses the public interface only.
- [ ] It would survive a refactor of the internals.
- [ ] The code is the minimum for this test.
- [ ] You added nothing for a later test.

## Read the RED

A failure counts as RED only when all three hold:

- **The new test fails on its own assertion.** The output names the expected
  value and the actual value, and the actual value shows the behavior is
  missing.
- **It is the failure you predicted.** Say what you expect it to print before
  you run it, and compare.
- **Every other test in the file still passes.** A file that was already red
  hides which failure is yours.

Some failures prove nothing about the behavior, so they are not RED. Examples
are a missing file, a syntax error, a typo, a setup error, a timeout,
and another test failing. Fix the test, or add the smallest scaffold that lets
it run, such as an empty function. Run the file again, until the failure is
the assertion.

## MUST

- ✅ **Test first** — the first file you create or edit for any behavior is the test, every time
- ✅ **Baby steps** — one scenario at a time
- ✅ **See it fail for the right reason** — a test that never failed proves nothing, and nor does a setup error
- ✅ **Run the whole test file**, never a single test
- ✅ **Write the minimum that passes** — leave the rest for the next scenario
- ✅ **One task holds** its scenarios, its implementation, and one passing commit
- ✅ **A task can hold several scenarios** — the success, the errors, the edges

## NEVER

- ❌ **Write several tests, then build everything** — write one, see it fail, build that one
- ❌ **Split tests and implementation into separate tasks** — the cycle lives inside one task
- ❌ **Write implementation code before a failing test exists** — the test comes first, every time
- ❌ **Skip the RED step**
- ❌ **Commit before every test for the task passes**
- ❌ **Mix a formatting or style change into the task** — it goes in its own commit, before the real change

## A worked example

```
Task: Add flexible updateAudience()

Baby step 1:
  1. Write test: "updates only description"
     Predict: expected "new text", got "old text"
  2. Run tests -> see it FAIL (RED), and read the failure
     It printed the prediction, on the new assertion, and nothing else
     failed, so it counts. "Cannot find module" would not count
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

## The test itself

Load the `testing` skill before you write the first test. It carries what a
good test asserts, where a mock belongs, and how to name and assert.
