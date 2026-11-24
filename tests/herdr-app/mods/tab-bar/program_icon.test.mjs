import assert from "node:assert/strict";
import { test } from "node:test";
import { importWithFakeKit, t } from "./fake-gpui-kit.mjs";

const { programGlyph, programIcon } = await importWithFakeKit("../../../../herdr-app/mods/tab-bar/program-icon.js");

test("a glyph draws 14 px in its glyph color", () => {
  assert.equal(String(programGlyph(t, { key: "pi", tint: true, icon: "icons/pi.svg" })), 'svg("icons/pi.svg").size(14).text_color("#6c71c4")');
});

test("a glyph with no color of its own takes the text color", () => {
  assert.equal(String(programGlyph(t, { key: "x", tint: true, icon: "x.svg" })), 'svg("x.svg").size(14).text_color("#839496")');
});

// A picture, such as the violet pi of programs.json, keeps its own colors.
test("a picture draws 14 px as it is", () => {
  assert.equal(String(programGlyph(t, { key: "pi", tint: false, icon: "icons/pi.svg" })), 'image("icons/pi.svg").w(14).h(14)');
});

test("a status that is not idle puts its dot on the corner of the icon", () => {
  assert.equal(
    String(programIcon(t, { program: { tint: false, icon: "x.svg" } }, "working")),
    'div().relative().flex_none().w(14).h(14).flex().items_center().justify_center().child(image("x.svg").w(14).h(14)).child(div().absolute().top(-2).right(-2).w(7).h(7).rounded_full().bg("#b58900"))',
  );
});

test("an idle program has no dot", () => {
  assert.equal(
    String(programIcon(t, { program: { tint: false, icon: "x.svg" } }, "idle")),
    'div().relative().flex_none().w(14).h(14).flex().items_center().justify_center().child(image("x.svg").w(14).h(14))',
  );
});

test("a program with no icon draws an empty box", () => {
  assert.equal(
    String(programIcon(t, { program: { icon: null } }, "idle")),
    "div().relative().flex_none().w(14).h(14).flex().items_center().justify_center()",
  );
});
