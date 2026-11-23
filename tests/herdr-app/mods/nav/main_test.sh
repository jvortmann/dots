#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
MAIN="$ROOT/herdr-app/mods/nav/main.js"

function set_up() {
  [[ -f $MAIN ]] || bashunit::fail "missing the file under test: $MAIN"
}

function test_a_key_in_nvim_reaches_nvim_through_hc_keys() {
  assert_same 'exec ["/home/me/.local/bin/hc",["keys","t7","ctrl+l"],{"timeout":5000}]' "$(calls_of right nvim)"
}

function test_a_key_in_the_shell_moves_the_pane_with_pane_go() {
  assert_same 'run ["pane.go",{"direction":"down"}]' "$(calls_of down shell)"
}

function test_a_forward_that_fails_shows_the_error_and_the_next_key_still_works() {
  assert_same "$(printf '%s\n' \
    'exec ["/home/me/.local/bin/hc",["keys","t7","ctrl+h"],{"timeout":5000}]' \
    'notify [{"title":"Nav failed","body":"timed out","level":"error"}]' \
    'exec ["/home/me/.local/bin/hc",["keys","t7","ctrl+j"],{"timeout":5000}]' \
    'notify [{"title":"Nav failed","body":"timed out","level":"error"}]')" \
    "$(calls_of "left down" nvim reject)"
}

function test_hc_keys_that_exits_with_an_error_shows_its_message() {
  assert_same "$(printf '%s\n' \
    'exec ["/home/me/.local/bin/hc",["keys","t7","ctrl+k"],{"timeout":5000}]' \
    'notify [{"title":"Nav failed","body":"no terminal t7","level":"error"}]')" \
    "$(calls_of up nvim exit)"
}

function test_hc_keys_that_exits_with_an_error_and_no_message_shows_its_exit_code() {
  assert_same "$(printf '%s\n' \
    'exec ["/home/me/.local/bin/hc",["keys","t7","ctrl+k"],{"timeout":5000}]' \
    'notify [{"title":"Nav failed","body":"hc keys exited with code 1","level":"error"}]')" \
    "$(calls_of up nvim silent)"
}

# A send to the server in the label nvim.server fails when that nvim is gone.
function test_a_send_to_an_nvim_that_is_gone_moves_the_pane() {
  assert_same "$(printf '%s\n' \
    'exec ["/opt/homebrew/bin/nvim",["--server","/tmp/nv.sock","--remote-send","<C-h>"],{"timeout":500}]' \
    'run ["pane.go",{"direction":"left"}]')" \
    "$(calls_of left nvim gone /tmp/nv.sock)"
}

# A stopped nvim (ctrl-z) keeps its label, and a send to it never ends. A
# send that works takes about 25 ms, so the send stops after 500 ms.
function test_a_send_to_nvim_that_does_not_end_moves_the_pane_after_half_a_second() {
  assert_same "$(printf '%s\n' \
    'exec ["/opt/homebrew/bin/nvim",["--server","/tmp/nv.sock","--remote-send","<C-l>"],{"timeout":500}]' \
    'run ["pane.go",{"direction":"right"}]')" \
    "$(calls_of right nvim reject /tmp/nv.sock)"
}

# Prints each call that the nav mod makes to the app for the commands $1,
# while the focused pane p1 with terminal t7 runs the program $2. With $3
# set to reject, each exec fails with "timed out". With $3 set to exit, hc
# exits with code 1 and "no terminal t7". With $3 set to silent, hc exits
# with code 1 and prints nothing. With $3 set to gone, nvim exits with code 2,
# as it does when its server is gone. $4 is the label nvim.server of t7.
calls_of() {
  COMMANDS="$1" PROGRAM="$2" EXEC="${3:-}" SERVER="${4:-}" MAIN="$MAIN" mise x node@latest -- node --input-type=module -e '
    import { registerHooks } from "node:module";
    const { COMMANDS, PROGRAM, EXEC, SERVER } = process.env;
    globalThis.app = { commands: COMMANDS.split(" "), calls: [], program: PROGRAM, exec: EXEC, server: SERVER };
    const herdr = `
      const app = globalThis.app;
      const result = () => app.exec === "reject" ? Promise.reject(new Error("timed out"))
        : Promise.resolve(app.exec === "exit" ? { code: 1, stdout: "", stderr: "no terminal t7\\n" }
          : app.exec === "silent" ? { code: 1, stdout: "", stderr: "" }
          : app.exec === "gone" ? { code: 2, stdout: "", stderr: "E247: Failed to connect\\n" } : { code: 0, stdout: "", stderr: "" });
      const record = (name) => (...args) => { app.calls.push(name + " " + JSON.stringify(args)); return name === "exec" ? result() : null; };
      export const exec = record("exec");
      export const run = record("run");
      export const notify = record("notify");
      export const checking = () => false;
      export const home = () => "/home/me";
      export const focused = () => ({ space: "s1", tab: "w1", pane: "p1", terminal: "t7", shown: null });
      export const panes = () => [{ pane: "p1", terminal: "t7", program: { key: app.program } }];
      export const terminals = () => [{ address: "t7", labels: app.server ? { "nvim.server": app.server } : {} }];
      export const nextCommand = () => (app.commands.length ? Promise.resolve(app.commands.shift()) : new Promise(() => {}));
    `;
    const kit = "export class View {}; export const div = () => ({});";
    const url = (code) => `data:text/javascript,${encodeURIComponent(code)}`;
    registerHooks({
      resolve: (specifier, context, next) =>
        specifier === "herdr" ? { url: url(herdr), shortCircuit: true }
        : specifier === "gpui-kit" ? { url: url(kit), shortCircuit: true }
        : next(specifier, context),
    });
    const { default: Nav } = await import(process.env.MAIN);
    const cx = { spawn: (task) => task(cx) };
    new Nav().init({}, cx);
    await new Promise((done) => setTimeout(done, 50));
    console.log(globalThis.app.calls.join("\n"));
  '
}
