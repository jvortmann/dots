# Tests

The tests are bashunit shell tests (`*_test.sh`) and node:test files
(`*.test.mjs`). Both live in `tests/`, in a layout that matches the files they
test. For example, `pi/pi-permissions.jsonc` has its test in
`tests/pi/permissions_test.sh`.

Run the full suite from the root with `tests/run`. It runs bashunit and
`node --test` side by side, each in a terminal of its own, and prints one
summary. It fails on a failed test, on a test over 10 seconds, and on a run
over 8 seconds. It takes about 6 seconds.

Run one file with `bashunit tests/<path>_test.sh` or
`node --test tests/<path>.test.mjs`. Run one file while you work, and the full
suite once at the end.
