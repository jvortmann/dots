import assert from "node:assert/strict";
import { test } from "node:test";
import { toggleChanges } from "../../../../herdr-app/mods/tab-bar/changes-panel.js";

const SHOW = '[["layout.select",{"stack":"panel-body","child":"changes"}],["layout.show",{"id":"panel"}]]';

test("a click while the panel is hidden shows the changes in it", () => {
  assert.equal(clicked(layoutWith(true, "changes")), SHOW);
});

test("a click while the panel shows the changes hides it", () => {
  assert.equal(clicked(layoutWith(false, "changes")), '[["layout.hide",{"id":"panel"}]]');
});

test("a click while the panel shows another view shows the changes in it", () => {
  assert.equal(clicked(layoutWith(false, "files")), SHOW);
});

function layoutWith(hidden, active) {
  return { id: "root", children: [{ id: "main" }, { id: "panel", hidden, children: [{ id: "panel-body", active }] }] };
}

function clicked(layout) {
  return JSON.stringify(toggleChanges(layout));
}
