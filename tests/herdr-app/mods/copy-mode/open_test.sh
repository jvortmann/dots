#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
OPEN="$ROOT/herdr-app/mods/copy-mode/open.js"

function set_up() {
  [[ -f $OPEN ]] || bashunit::fail "missing the file under test: $OPEN"
  command -v node > /dev/null || bashunit::skip "needs node"
}

function test_shows_the_warm_nvim_in_the_pane_once_it_has_opened_copy_mode() {
  assert_same '["exec","nvim","--server","/run/nvim.0","--remote-expr","v:lua.copy_mode_open(\"t7\")"]
["terminal.show",{"terminal":"t9","pane":"p1"}]' \
    "$(scenario 'await openCopyMode(app, { source: "t7", pane: "p1", nvim: warm("t9", "/run/nvim.0") });')"
}

function test_shows_nothing_and_says_why_when_nvim_cannot_open_copy_mode() {
  assert_same '["error","Lua: Vim:E5108: Lua: cannot read t7"]' "$(scenario '
    results.exec = { code: 2, stdout: "", stderr: "Lua: Vim:E5108: Lua: cannot read t7\nstack traceback:\n" };
    await openCopyMode(app, { source: "t7", pane: "p1", nvim: warm("t9", "/run/nvim.0") });' | grep -v '^\["exec"\|^\["hc"')"
}

function test_ends_the_warm_nvim_that_cannot_open_copy_mode() {
  assert_same '["hc","kill","t9"]' "$(scenario '
    results.exec = { code: 2, stdout: "", stderr: "E247: Failed to connect" };
    await openCopyMode(app, { source: "t7", pane: "p1", nvim: warm("t9", "/run/nvim.0") });' | grep '^\["hc"')"
}

function test_says_how_nvim_ended_when_it_gives_no_reason() {
  assert_same '["error","nvim exited with code 2"]' "$(scenario '
    results.exec = { code: 2, stdout: "", stderr: "" };
    await openCopyMode(app, { source: "t7", pane: "p1", nvim: warm("t9", "/run/nvim.0") });' | grep '^\["error"')"
}

function test_takes_the_warm_nvim_that_tells_where_its_server_listens() {
  assert_same '["took","t9"]' "$(scenario '
    listed = [{ address: "t3", state: "live", labels: {} }, warm("t9", "/run/nvim.0")];
    const nvim = await new Standby(app, "/v.sh").take(never);
    calls.push(["took", nvim?.address ?? null]);')"
}

function test_takes_each_warm_nvim_once() {
  assert_same '["error","no warm nvim is ready for copy mode"]' "$(scenario '
    listed = [warm("t9", "/run/nvim.0")];
    const standby = new Standby(app, "/v.sh");
    await standby.take(never);
    await standby.take(Promise.resolve());')"
}

function test_waits_for_a_warm_nvim_that_becomes_ready_after_the_key() {
  assert_same '["took","t9"]' "$(scenario '
    const standby = new Standby(app, "/v.sh");
    const taken = standby.take(never);
    listed = [warm("t9", "/run/nvim.0")];
    standby.ready();
    calls.push(["took", (await taken).address]);')"
}

function test_starts_a_warm_nvim_when_none_is_ready() {
  assert_same '["hc","run","--bg","--json","--no-parent","--no-notify","--rm","--cwd","/home","--","/bin/sh","/v.sh"]' "$(scenario '
    const standby = new Standby(app, "/v.sh");
    if (standby.shouldStart()) await standby.start();')"
}

function test_starts_one_warm_nvim_at_a_time() {
  assert_same '["should start",true,false]' "$(scenario '
    const standby = new Standby(app, "/v.sh");
    calls.push(["should start", standby.shouldStart(), standby.shouldStart()]);')"
}

function test_starts_the_next_warm_nvim_once_the_last_one_is_taken() {
  assert_same '["should start",true]' "$(scenario '
    const standby = new Standby(app, "/v.sh");
    standby.shouldStart();
    listed = [warm("t9", "/run/nvim.0")];
    await standby.take(never);
    calls.push(["should start", standby.shouldStart()]);')"
}

function test_starts_again_when_no_warm_nvim_became_ready_in_time() {
  assert_same '["should start",true]' "$(scenario '
    const standby = new Standby(app, "/v.sh");
    standby.shouldStart();
    await standby.take(Promise.resolve()).catch(() => {});
    calls.push(["should start", standby.shouldStart()]);')"
}

function test_says_why_a_warm_nvim_cannot_start_and_starts_again() {
  assert_same '["error","the core is down"]
["should start",true]' "$(scenario '
    results.hc = { code: 1, stdout: "", stderr: "the core is down" };
    const standby = new Standby(app, "/v.sh");
    standby.shouldStart();
    await standby.start().catch((error) => calls.push(["error", error.message]));
    calls.push(["should start", standby.shouldStart()]);' | grep -v '^\["hc"')"
}

function test_closing_ends_the_warm_nvims() {
  assert_same '["hc","kill","t8"]
["hc","kill","t9"]' "$(scenario '
    const standby = new Standby(app, "/v.sh");
    standby.shouldStart();
    await standby.start();
    listed = [warm("t8", "/run/nvim.1"), { address: "t3", state: "live", labels: {} }];
    await standby.close();' | grep '^\["hc","kill"')"
}

function test_closing_ends_a_warm_nvim_that_was_not_ready_in_time() {
  assert_same '["hc","kill","t8"]
["hc","kill","t9"]' "$(scenario '
    const standby = new Standby(app, "/v.sh");
    results.hc = { code: 0, stdout: "{\"address\":\"t8\"}", stderr: "" };
    standby.shouldStart();
    await standby.start();
    await standby.take(Promise.resolve()).catch(() => {});
    results.hc = { code: 0, stdout: "{\"address\":\"t9\"}", stderr: "" };
    standby.shouldStart();
    await standby.start();
    await standby.close();' | grep '^\["hc","kill"')"
}

# Runs the JavaScript in $1 with the exports of open.js and a stand-in app.
# The app lists the terminals in the variable listed. Its exec and hc return
# results.exec and results.hc. The function warm(address, server) describes a
# warm nvim, and never is a time limit that never ends. Prints each call to
# the app and each error as one JSON line.
scenario() {
  node --input-type=module -e "
    import { openCopyMode, Standby } from '$OPEN';
    const calls = [];
    let listed = [];
    const results = { exec: { code: 0, stdout: '', stderr: '' }, hc: { code: 0, stdout: '{\"address\":\"t9\"}', stderr: '' } };
    const app = {
      home: '/home',
      exec: async (command, args) => (calls.push(['exec', command, ...args]), results.exec),
      hc: async (args) => (calls.push(['hc', ...args]), results.hc),
      run: (name, args) => calls.push([name, args]),
      terminals: () => listed,
    };
    const warm = (address, server) => ({ address, state: 'live', labels: { 'copy-mode.standby': server } });
    const never = new Promise(() => {});
    try {
      $1
    } catch (error) {
      calls.push(['error', error.message]);
    }
    for (const call of calls) console.log(JSON.stringify(call));
  " < /dev/null
}
