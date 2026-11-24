import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { test } from "node:test";
import { alpha } from "../../../../herdr-app/mods/tab-bar/alpha.js";

const MODS = new URL("../../../../herdr-app/mods/", import.meta.url);

test("an opaque color takes the share as its alpha", () => {
  assert.equal(alpha("#586e75", 0.25), "#586e7540");
});

// The border of atom-one-dark is #ffffff18. A second alpha byte after it is no
// color, and the tab bar failed to draw.
test("a color with an alpha of its own keeps the share of that alpha", () => {
  assert.equal(alpha("#ffffff18", 0.25), "#ffffff06");
});

// The app reads #rgb, #rrggbb and #rrggbbaa, and no #rgba. So a theme color
// has no #rgba form.
test("a short color takes the long form with the share as its alpha", () => {
  assert.equal(alpha("#abc", 0.25), "#aabbcc40");
});

// The mod loader rejects an import from another mod folder, so each mod keeps
// a copy.
test("the recent picker keeps the same alpha rule", () => {
  const read = (path) => readFileSync(new URL(path, MODS), "utf8");
  assert.equal(read("recent-picker/alpha.js"), read("tab-bar/alpha.js"));
});
