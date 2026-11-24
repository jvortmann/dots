import assert from "node:assert/strict";
import { test } from "node:test";
import { shouldMaximize } from "../../../../herdr-app/mods/window/maximize.js";

test("a window that is not maximized gets maximized", () => {
  assert.equal(shouldMaximize({ maximized: false, fullscreen: false }), true);
});

test("a maximized window stays as it is", () => {
  assert.equal(shouldMaximize({ maximized: true, fullscreen: false }), false);
});

test("a window in full screen stays as it is", () => {
  assert.equal(shouldMaximize({ maximized: false, fullscreen: true }), false);
});

test("nothing maximizes while the app has no window", () => {
  assert.equal(shouldMaximize(null), false);
});
