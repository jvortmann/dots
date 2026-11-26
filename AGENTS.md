# Tests

The tests live in `tests/`, in a layout that matches the files they test. For
example, `pi/pi-permissions.jsonc` has its test in
`tests/pi/permissions_test.sh`. The JS logic of the Herdr mods and the pi
extensions has node:test files (`*.test.mjs`). The other tests are bashunit
shell tests (`*_test.sh`).

Run the full suite from the root with `tests/run`. It runs bashunit and
`node --test` side by side, each test file in a terminal of its own. As each
test ends, it prints the path of its test file and its name. Then it prints the
failures in full and one summary.

The run fails on a failed test, on a test over 10 seconds, and on a run over 10
seconds. When several runs go at once, both limits grow by the number of runs.
A run alone takes about 8 seconds.

Run one file with `bashunit tests/<path>_test.sh` or
`node --test tests/<path>.test.mjs`. While you work, run only the test file
you change. Run the full suite at the end of the task. Run it again only when a
fix after the review changes a file. One suite fills every core, and other
agents can run their suites at the same time.

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

# Herdr

The user works in the Herdr app, so its window and its core, herdr-core, are
live. The setup links each config folder as a whole: `~/.config/herdr-app` is a
link to `herdr-app/`, and `~/.config/herdr-core` is a link to `herdr-core/`. An
edit in `herdr-app/` reaches the running app in about a second. The app
also writes its own files into `herdr-app/`, so `git/ignore` keeps an allow
list for it. A new mod, layout or theme needs an allow line there.

The docs and the types are `herdr-app/AGENTS.md`, `herdr-app/herdr.d.ts` and
`herdr-app/gpui-kit.d.ts`. The app writes them at each start. The programs are
`~/.local/bin/herdr-app` and `~/.local/bin/hc`.

Check a change in a scratch core and a scratch window:

- Give the scratch core its own `HC_SESSION`, a short `HC_SOCKET` in `/tmp`
  (the limit is 103 bytes), and a scratch `HOME`, `XDG_CONFIG_HOME` and
  `XDG_STATE_HOME`. The function `in_scratch` in
  `tests/herdr-core/config_test.sh` shows how.
- Give the scratch window its own `HERDR_APP_HOME`, with its current folder in
  a scratch folder under `/tmp/scratch`.
- Stop each scratch core before you finish. Run `hc server stop` with the same
  scratch values, as `in_scratch` does. A bare `hc server stop` stops the core
  of the user.

Never run these on the window or the core of the user:

- `herdr-app do`, `herdr-app shot`, or a start of the app from a shell
- `hc server`, `hc label`, `hc send` or `hc keys`

When a check needs the window of the user, stop and give the user the steps.

# Plans

Git ignores `plans/`, so an edit to a plan needs no commit.
