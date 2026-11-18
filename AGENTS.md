# Tests

The tests are bashunit shell tests in `tests/`. The layout matches the files
they test. For example, `pi/pi-permissions.jsonc` has its test in
`tests/pi/permissions_test.sh`.

Run one file with `bashunit tests/<path>_test.sh` from the root. Run all of
them with `bashunit tests/`. The full suite takes about 40 seconds. Run one
file while you work, and the full suite once at the end.
