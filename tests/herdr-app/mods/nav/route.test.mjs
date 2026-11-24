import assert from "node:assert/strict";
import { test } from "node:test";
import { route } from "../../../../herdr-app/mods/nav/route.js";

test("a key in nvim goes on to nvim so that it moves between its own windows", () => {
  assert.equal(routeOf("down", focus(), panesWith("nvim")), '{"exec":["/home/me/.local/bin/hc",["keys","t7","ctrl+j"]]}');
});

// hc keys waits for 3 s of quiet after a key of the person, so a key goes to
// the server that nvim gives in the label nvim.server. When that send fails,
// nvim is gone, and the pane moves.
test("a key in nvim goes to the server that nvim gives in its label", () => {
  assert.equal(
    routeOf("down", focus(), panesWith("nvim"), terminalsWith("/tmp/nv.sock")),
    '{"exec":["/opt/homebrew/bin/nvim",["--server","/tmp/nv.sock","--remote-send","<C-j>"]],"failed":["pane.go",{"direction":"down"}]}',
  );
});

// Herdr shows the program that started nvim, such as git for its editor.
test("a key in nvim under another program goes to the server in the label", () => {
  assert.equal(
    routeOf("left", focus(), panesWith("program"), terminalsWith("/tmp/nv.sock")),
    '{"exec":["/opt/homebrew/bin/nvim",["--server","/tmp/nv.sock","--remote-send","<C-h>"]],"failed":["pane.go",{"direction":"left"}]}',
  );
});

// Herdr shows a bash script, such as bashunit, as the program shell.
test("a key while the shell runs a command moves the pane in its direction", () => {
  assert.equal(routeOf("down", focus(), panesWith("shell")), '{"run":["pane.go",{"direction":"down"}]}');
});

// Copy mode shows its nvim in the pane with terminal.show. pane.go keeps
// copy mode shown in its pane.
test("a key in copy mode moves the pane in its direction though copy mode runs nvim", () => {
  assert.equal(routeOf("up", focus("t9"), panesWith("nvim")), '{"run":["pane.go",{"direction":"up"}]}');
});

test("a key in copy mode over nvim with its label moves the pane in its direction", () => {
  assert.equal(routeOf("up", focus("t9"), panesWith("nvim"), terminalsWith("/tmp/nv.sock")), '{"run":["pane.go",{"direction":"up"}]}');
});

test("a key while nothing has the focus runs pane go in its direction", () => {
  assert.equal(routeOf("left", null, panesWith("nvim")), '{"run":["pane.go",{"direction":"left"}]}');
});

test("a key in pi moves the pane in its direction", () => {
  assert.equal(routeOf("right", focus(), panesWith("pi")), '{"run":["pane.go",{"direction":"right"}]}');
});

test("a key moves the pane in its direction while the panes do not list the focused one yet", () => {
  assert.equal(
    routeOf("left", focus(), [{ pane: "p2", terminal: "t8", program: { key: "shell" } }]),
    '{"run":["pane.go",{"direction":"left"}]}',
  );
});

// Gives, as JSON, what the nav mod does with the command while the focus is
// the value of focused(), over the panes of panes() and the terminals of
// terminals() (default: none). The home folder is /home/me.
function routeOf(command, focused, panes, terminals = []) {
  return JSON.stringify(route(command, focused, panes, terminals, "/home/me"));
}

// terminals(): terminal t8, and terminal t7 with the label nvim.server set to
// the server.
function terminalsWith(server) {
  return [{ address: "t8", labels: {} }, { address: "t7", labels: { "nvim.server": server } }];
}

// focused() on pane p1 with terminal t7, and the terminal shown over it when
// set.
function focus(shown = null) {
  return { space: "s1", tab: "w1", pane: "p1", terminal: "t7", shown };
}

// panes(): pane p2 with a shell, and the focused pane p1 with terminal t7,
// which runs the program.
function panesWith(program) {
  return [
    { pane: "p2", terminal: "t8", program: { key: "shell" }, focused: false },
    { pane: "p1", terminal: "t7", program: { key: program }, focused: true },
  ];
}
