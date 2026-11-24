import assert from "node:assert/strict";
import { registerHooks } from "node:module";
import { test } from "node:test";

const HC = (key) => `exec ["/home/me/.local/bin/hc",["keys","t7","${key}"],{"timeout":5000}]`;
const FAILED = (body) => `notify [{"title":"Nav failed","body":"${body}","level":"error"}]`;

// A fake herdr records each call of the mod in globalThis.app. Each test sets
// a new app, so the fake reads it at each call.
const herdr = `
  const app = () => globalThis.app;
  const result = () => app().exec === "reject" ? Promise.reject(new Error("timed out"))
    : Promise.resolve(app().exec === "exit" ? { code: 1, stdout: "", stderr: "no terminal t7\\n" }
      : app().exec === "silent" ? { code: 1, stdout: "", stderr: "" }
      : app().exec === "gone" ? { code: 2, stdout: "", stderr: "E247: Failed to connect\\n" } : { code: 0, stdout: "", stderr: "" });
  const record = (name) => (...args) => { app().calls.push(name + " " + JSON.stringify(args)); return name === "exec" ? result() : null; };
  export const exec = record("exec");
  export const run = record("run");
  export const notify = record("notify");
  export const checking = () => false;
  export const home = () => "/home/me";
  export const focused = () => ({ space: "s1", tab: "w1", pane: "p1", terminal: "t7", shown: null });
  export const panes = () => [{ pane: "p1", terminal: "t7", program: { key: app().program } }];
  export const terminals = () => [{ address: "t7", labels: app().server ? { "nvim.server": app().server } : {} }];
  export const nextCommand = () => {
    const app_ = app();
    if (app_.commands.length) return Promise.resolve(app_.commands.shift());
    app_.waiting();
    return new Promise(() => {});
  };
`;
const kit = "export class View {}; export const div = () => ({});";
const url = (code) => `data:text/javascript,${encodeURIComponent(code)}`;
registerHooks({
  resolve: (specifier, context, next) =>
    specifier === "herdr" ? { url: url(herdr), shortCircuit: true }
    : specifier === "gpui-kit" ? { url: url(kit), shortCircuit: true }
    : next(specifier, context),
});
const { default: Nav } = await import("../../../../herdr-app/mods/nav/main.js");

test("a key in nvim reaches nvim through hc keys", async () => {
  assert.equal(await callsOf("right", "nvim"), HC("ctrl+l"));
});

test("a key in the shell moves the pane with pane go", async () => {
  assert.equal(await callsOf("down", "shell"), 'run ["pane.go",{"direction":"down"}]');
});

test("a forward that fails shows the error and the next key still works", async () => {
  assert.equal(await callsOf("left down", "nvim", "reject"), [HC("ctrl+h"), FAILED("timed out"), HC("ctrl+j"), FAILED("timed out")].join("\n"));
});

test("hc keys that exits with an error shows its message", async () => {
  assert.equal(await callsOf("up", "nvim", "exit"), [HC("ctrl+k"), FAILED("no terminal t7")].join("\n"));
});

test("hc keys that exits with an error and no message shows its exit code", async () => {
  assert.equal(await callsOf("up", "nvim", "silent"), [HC("ctrl+k"), FAILED("hc keys exited with code 1")].join("\n"));
});

// A send to the server in the label nvim.server fails when that nvim is gone.
test("a send to an nvim that is gone moves the pane", async () => {
  assert.equal(
    await callsOf("left", "nvim", "gone", "/tmp/nv.sock"),
    'exec ["/opt/homebrew/bin/nvim",["--server","/tmp/nv.sock","--remote-send","<C-h>"],{"timeout":500}]\nrun ["pane.go",{"direction":"left"}]',
  );
});

// A stopped nvim (ctrl-z) keeps its label, and a send to it never ends. A
// send that works takes about 25 ms, so the send stops after 500 ms.
test("a send to nvim that does not end moves the pane after half a second", async () => {
  assert.equal(
    await callsOf("right", "nvim", "reject", "/tmp/nv.sock"),
    'exec ["/opt/homebrew/bin/nvim",["--server","/tmp/nv.sock","--remote-send","<C-l>"],{"timeout":500}]\nrun ["pane.go",{"direction":"right"}]',
  );
});

// Gives each call that the nav mod makes to the app for the commands, while
// the focused pane p1 with terminal t7 runs the program. With exec set to
// reject, each exec fails with "timed out". With exit, hc exits with code 1
// and "no terminal t7". With silent, hc exits with code 1 and prints nothing.
// With gone, nvim exits with code 2, as it does when its server is gone. The
// server is the label nvim.server of t7. The calls are ready when the mod asks
// for the command after the last one.
function callsOf(commands, program, exec = "", server = "") {
  return new Promise((done) => {
    globalThis.app = { commands: commands.split(" "), calls: [], program, exec, server, waiting: () => done(globalThis.app.calls.join("\n")) };
    const cx = { spawn: (task) => task(cx) };
    new Nav().init({}, cx);
  });
}
