import assert from "node:assert/strict";
import { test } from "node:test";
import { glyphColor } from "../../../../herdr-app/mods/tab-bar/glyph.js";

const LIGHT = "#fdf6e3";
const DARK = "#002b36";

test("on a light canvas a white glyph takes the color of its dark tile", () => {
  assert.equal(glyphColor({ color: "#ffffff", tile: "#1c1d21" }, LIGHT, "fallback"), "#1c1d21");
});

test("on a dark canvas a white glyph stays white as before", () => {
  assert.equal(glyphColor({ color: "#ffffff", tile: "#1c1d21" }, DARK, "fallback"), "#ffffff");
});

test("on a dark canvas a glyph takes its tile color when the tile stands out enough", () => {
  assert.equal(glyphColor({ color: "#ffffff", tile: "#57a143" }, DARK, "fallback"), "#57a143");
});

test("the pi glyph takes the violet of the theme on both canvases", () => {
  const pi = { key: "pi", color: "#ffffff", tile: "#1c1d21" };
  const theme = { ansi13: "#6c71c4" };
  assert.equal(glyphColor(pi, DARK, "fallback", theme), "#6c71c4");
  assert.equal(glyphColor(pi, LIGHT, "fallback", theme), "#6c71c4");
});

test("another agent on a near black tile keeps white on a dark canvas", () => {
  assert.equal(glyphColor({ key: "claude", color: "#ffffff", tile: "#1c1d21" }, DARK, "fallback", { ansi13: "#6c71c4" }), "#ffffff");
});

test("a glyph with no color of its own takes the text color of the theme", () => {
  assert.equal(glyphColor({}, LIGHT, "fallback"), "fallback");
});
