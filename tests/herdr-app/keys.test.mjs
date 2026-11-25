import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { test } from "node:test";

const keys = JSON.parse(readFileSync(new URL("../../herdr-app/keys.json", import.meta.url), "utf8"));

test("ctrl-a t swaps the theme in the tab bar", () => {
  assert.equal(keys.global["ctrl-a t"], "tab-bar.swap-theme");
});
