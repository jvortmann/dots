import assert from "node:assert/strict";
import { test } from "node:test";
import { importWithFakeKit } from "./fake-gpui-kit.mjs";
import { fakeModules, NEXT_COMMAND } from "../fake-modules.mjs";

const SWAP = 'exec ["zsh",["-c","source ~/.dots/zsh/conf/plugins/theme.zsh; swap-theme"],{"timeout":5000}]';

// A fake herdr records each call of the mod in globalThis.app. Each test sets
// a new app, so the fake reads it at each call.
const herdr = `
  const app = () => globalThis.app;
  const record = (name) => (...args) => { app().calls.push(name + " " + JSON.stringify(args)); return name === "exec" ? app().exec() : null; };
  export const exec = record("exec");
  export const run = record("run");
  export const notify = record("notify");
  export const checking = () => true;
  export const props = () => null;
  ${NEXT_COMMAND}
  export const spaces = () => [], panes = () => [], agents = () => [], terminals = () => [], theme = () => ({}),
    openOverlay = () => {}, closeOverlay = () => {}, window = () => null, shared = () => null, setShared = () => {},
    hc = () => {}, appHome = () => "", readTextFile = () => "", writeTextFile = () => {}, layout = () => null;
`;
const base = "export const h_flex = () => ({}), v_flex = () => ({}), Input = {}, InputState = {};";
fakeModules({ herdr, "gpui-base": base });
const { default: TabBar } = await importWithFakeKit("../../../../herdr-app/mods/tab-bar/main.js");

test("swap-theme runs the swap-theme function of zsh for at most 5 seconds", async () => {
  assert.equal(await callsOf("swap-theme"), SWAP);
});

test("a theme swap that exits with an error shows its message", async () => {
  const failed = () => Promise.resolve({ code: 127, stdout: "", stderr: "zsh:1: command not found: swap-theme\n" });
  assert.equal(
    await callsOf("swap-theme", failed),
    [SWAP, 'notify [{"title":"Theme swap failed","body":"zsh:1: command not found: swap-theme","level":"error"}]'].join("\n"),
  );
});

test("a theme swap that exits with an error and no message shows its exit code", async () => {
  const failed = () => Promise.resolve({ code: 1, stdout: "", stderr: "" });
  assert.equal(
    await callsOf("swap-theme", failed),
    [SWAP, 'notify [{"title":"Theme swap failed","body":"swap-theme exited with code 1","level":"error"}]'].join("\n"),
  );
});

test("a theme swap that cannot run shows the error and the next key still works", async () => {
  const failed = 'notify [{"title":"Theme swap failed","body":"timed out","level":"error"}]';
  assert.equal(await callsOf("swap-theme swap-theme", () => Promise.reject(new Error("timed out"))), [SWAP, failed, SWAP, failed].join("\n"));
});

// Gives each call that the bar makes to the app for the commands. Each exec
// gives the result of exec. The calls are ready when the bar asks for the
// command after the last one, or when its command loop stops.
function callsOf(commands, exec = () => Promise.resolve({ code: 0, stdout: "", stderr: "" })) {
  return new Promise((done) => {
    globalThis.app = { commands: commands.split(" "), calls: [], exec, waiting: () => done(globalThis.app.calls.join("\n")) };
    const stopped = (error) => done([...globalThis.app.calls, `stopped ${error.message}`].join("\n"));
    const cx = { spawn: (task) => Promise.resolve(task(cx)).catch(stopped), timer: { after: () => {} } };
    new TabBar().init({}, cx);
  });
}
