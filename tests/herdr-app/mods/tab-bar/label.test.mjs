import assert from "node:assert/strict";
import { test } from "node:test";
import { tabText } from "../../../../herdr-app/mods/tab-bar/label.js";

test("a renamed tab shows its name", () => {
  assert.equal(JSON.stringify(tabText({ index: 2, name: "api", named: true })), '"api"');
});

test("a tab nobody named shows the process in its terminal", () => {
  const terminal = { address: "t7", foreground: { name: "zsh" } };
  assert.equal(JSON.stringify(tabText({ index: 2, name: "2", named: false }, terminal)), '"zsh"');
});

test("a renamed tab keeps its name while a process runs in it", () => {
  const terminal = { address: "t7", foreground: { name: "zsh" } };
  assert.equal(JSON.stringify(tabText({ index: 2, name: "api", named: true }, terminal)), '"api"');
});

test("a tab nobody named with no process shows no text", () => {
  assert.equal(JSON.stringify(tabText({ index: 2, name: "2", named: false })), '""');
});

test("a tab nobody named shows the process name and not the program name", () => {
  const terminal = { address: "t7", foreground: { name: "nvim" }, program: { key: "nvim", name: "Neovim" } };
  assert.equal(JSON.stringify(tabText({ index: 2, name: "2", named: false }, terminal)), '"nvim"');
});
