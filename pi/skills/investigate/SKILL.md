---
name: investigate
description: Load whenever a bug, a failure or a wrong output needs its cause found, every time, and before the first line of a fix. That covers a test that fails without warning, an error in a log, a report from a user, and a question such as why something happens. It carries the fixed order of the work, the ways to cut the search, and the two outcomes a finding states.
---

# Investigate

Find the cause of a failure, with evidence, before you fix it. The work ends at
a named cause, and not at a fix.

## Evidence beats a guess

- A guess chooses the next probe. It is never the finding. Trust the output you
  saw over what the code should do.
- Change one thing in each probe, so the result points at one cause.
- An empty result proves nothing until a positive control passes. Run the same
  query against a case you know exists. A wrong field, time window or pattern
  also comes back empty.

## The order

Keep this order. How you do each step is your choice.

1. **Make it fail on demand.** Capture one failing case, with the exact input
   and the exact wrong output. Then write a command that triggers it again.
   Every later step reads that command. When nothing triggers the failure, say
   so, and work from the recorded evidence alone.
2. **Read what the system recorded.** Read the logs, the captured output and
   the stored data. Do this before you reason about what the code should do.
3. **Narrow.** Cut the suspect region in half until one component is left. Cut
   first at the recent changes and at the boundaries between components.
4. **Run the real input through the real code path.** Call the real function,
   and not a copy or a similar one that looks right. Read the output it gives.
5. **Trace back to a line.** Follow the bad output back to where the bad value
   starts. Name the function and its `file:line`, and prove which branch ran.

## Ways to cut

Choose by the shape of the failure.

- **Bisect the history**, when the behavior was correct before. Give the
  command from step 1 to `git bisect run`. The commit it finds is a lead, not
  the cause. Read its diff and continue to trace.
- **Bisect the pipeline**, when data goes through stages. Check the value at
  the middle stage. A correct value puts the fault after it, and a wrong value
  puts it before. Do the same again on the half that is left.
- **Instrument the boundaries**, when several components hide which one is
  wrong. Log what goes in and out of each one, with its config and environment,
  and run once. Open the layer where good input becomes bad output. Log before
  the suspect operation, not after it fails. When a bad value comes from an
  unknown caller, print a stack trace with the value.
- **Diff a working case**, when a similar case succeeds. Compare the input, the
  config, the environment and the order of calls in full. List every difference
  before you set one aside. When it works on one machine only, name the
  difference before you change code. Look at versions, config, file layout,
  locale, clock and credentials.

A failure that comes and goes points at shared state, timing, the order of
events, or a polluting test. Run the tests one at a time to find the polluter.

## When it resists

After a few probes that narrow nothing, do not repeat them. Name an assumption
you never checked, and test it. When the evidence points outside the code, such
as the environment, timing or an external service, follow it there.

## Report one outcome

Write the finding: the symptom, the command that triggers it, and the trail of
evidence. The trail says what you probed, what you saw and what you ruled out.
Then state one outcome.

- **cause named**: the `file:line`, and the output that shows it. A cause that
  rests on argument alone does not count.
- **inconclusive**: what you ruled out, and the next probe to run.

Never report a third outcome such as "probably" or "likely". A cause without
output behind it is inconclusive.

Load the `tdd` skill for the fix. The failing case from step 1 becomes its
first RED test.
