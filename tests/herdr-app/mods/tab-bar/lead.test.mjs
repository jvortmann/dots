import assert from "node:assert/strict";
import { test } from "node:test";
import { lead } from "../../../../herdr-app/mods/tab-bar/lead.js";

const leadOf = (tab, panes) => String(lead(panes, tab)?.program.key);

test("the focused pane of a tab leads it", () => {
  assert.equal(leadOf("t1", [{ tab: "t1", program: { key: "shell" } }, { tab: "t1", focused: true, program: { key: "nvim" } }]), "nvim");
});

test("the focused pane leads even when an agent runs in another pane", () => {
  assert.equal(leadOf("t1", [{ tab: "t1", program: { key: "pi", agent: true } }, { tab: "t1", focused: true, program: { key: "shell" } }]), "shell");
});

test("with no focused pane the agent pane leads", () => {
  assert.equal(leadOf("t1", [{ tab: "t1", program: { key: "shell" } }, { tab: "t1", program: { key: "pi", agent: true } }]), "pi");
});

test("with no focused pane and no agent the first pane leads", () => {
  assert.equal(leadOf("t1", [{ tab: "t1", program: { key: "shell" } }, { tab: "t1", program: { key: "nvim" } }]), "shell");
});

test("a pane of another tab never leads", () => {
  assert.equal(leadOf("t1", [{ tab: "t2", focused: true, program: { key: "nvim" } }, { tab: "t1", program: { key: "shell" } }]), "shell");
});
