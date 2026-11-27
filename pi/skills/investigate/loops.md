# Feedback loops

A loop is one command that fails on this bug. Every later step of the
investigation reads its verdict. Without it, reading code only produces
theories.

Use only tools that are already installed. When a loop needs another tool, ask
the user. Every loop obeys three files in `$PI_CODING_AGENT_DIR`. `AGENTS.md`
holds the macOS privacy rules. `agents/dev.md` holds the `timeout` rule for a
run. `APPEND_SYSTEM.md` holds the `gob` rule for a server.

## Ways to build one

Try them in this order. Use the first that reaches the bug.

1. **A failing test at the seam** that reaches the bug: unit, integration or
   end to end.
2. **An HTTP script** against a server that runs already, or one that you
   start through `gob`.
3. **A CLI run against a snapshot.** Give it a fixture input and diff the
   output against a known good copy.
4. **A replay of a captured trace.** Save a real request, payload or event log
   to a file. Send it through the code path alone.
5. **A throwaway harness.** Start the smallest part of the system that holds
   the code path, with mocks for the rest, and call it once.
6. **A property loop.** When the output is wrong only sometimes, run many
   random inputs and look for the one that fails.
7. **`git bisect run`**, when the behavior was correct at an earlier state.
   The command must give a clean pass or fail at each state.
8. **An old-against-new diff.** Send one input through both versions, or two
   configs, and compare the outputs.
9. **A human step**, as a last resort and only when a person must click or
   look. Give the user numbered steps as text. Ask what they saw with
   `ask_user_question`, or return the steps to the main session. Ask for an
   observation only, never a secret. Write no script for it.

## Tighten it

Once a loop exists, improve it. A loop that takes seconds and gives the same
verdict each time is worth the work.

- **Faster.** Cache the setup, skip unrelated init, and run a narrower scope.
- **Sharper.** Assert on the exact symptom, not on "did not crash".
- **Deterministic.** Pin the time, seed the random source, and isolate the file
  system in a scratch folder.

## A flaky failure

The goal is a high reproduction rate, not one clean run. Run the trigger 100
times and count the failures. Then raise the rate: run a few copies in
parallel, each under `timeout`, add load, and narrow the timing window. A
failure at 50 percent is easy to debug. One at 1 percent is not, so keep
raising the rate. Report the final rate with the command.

## When no loop is possible

Say so, and list what you tried. Work from the recorded evidence alone. The
outcome stays inconclusive until the evidence names a line. Ask the user for
access to an environment that reproduces it. Or ask for a captured artifact
with the secrets removed, or for permission to add temporary instrumentation.
