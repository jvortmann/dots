# Tests

The tests live in `tests/`, in a layout that matches the files they test. For
example, `pi/pi-permissions.jsonc` has its test in
`tests/pi/permissions_test.sh`. The JS logic of the Herdr mods and the pi
extensions has node:test files (`*.test.mjs`). The other tests are bashunit
shell tests (`*_test.sh`).

Run the full suite from the root with `tests/run`. It runs bashunit and
`node --test` side by side, each test file in a terminal of its own. As each
test ends, it prints the path of its test file and its name. Then it prints the
failures in full and one summary. It fails on a failed test, on a test over 10
seconds, and on a run over 8 seconds. It takes about 6 seconds.

Run one file with `bashunit tests/<path>_test.sh` or
`node --test tests/<path>.test.mjs`. Run one file while you work, and the full
suite once at the end.

A fake program is a link to `tests/fakes/fake`, which `fake_program` in
`tests/fakes/fakes.sh` makes. Do not write a new program file in a test. macOS
checks each new program at its first start, which costs 150 to 450
milliseconds.

The rules for a test:

- Avoid waits and sleeps at all cost. Wait on a signal from the code, such as a
  FIFO or `tmux wait-for`, and not on the clock.
- No test reads the terminal. Give each shell `</dev/null`, and give
  `zsh -i` the option `+Z`. In `tests/run`, a test that reads the terminal
  fails at the limit of 10 seconds.
- A test that checks behavior stays. Make a slow test fast, and do not cut it.
- Cut only a test that restates a config or repeats another test.
