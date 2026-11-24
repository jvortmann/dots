import assert from "node:assert/strict";
import { test } from "node:test";
import { openingTab, recentSpaces } from "../../../../herdr-app/mods/recent-picker/order.js";
import { parseShot } from "../shots.js";

test("the spaces go from the shown space to the space shown longest ago", () => {
  assert.equal(spacesInOrder("s3 s4 s1 s2", "s1:*t1 s2:*u1 *s3:*v1 s4:*w1"), "s3 s4 s1 s2");
});

test("the spaces never shown come last in the order of the sidebar", () => {
  assert.equal(spacesInOrder("s3", "s1:*t1 s2:*u1 *s3:*v1 s4:*w1"), "s3 s1 s2 s4");
});

test("a closed space in the record does not show", () => {
  assert.equal(spacesInOrder("s3 s2 s1", "s1:*t1 *s3:*v1"), "s3 s1");
});

test("the shown space comes first when the record does not name it yet", () => {
  assert.equal(spacesInOrder("", "s1:*t1 *s2:*u1"), "s2 s1");
});

test("the picker opens on the tab that the previous space showed last", () => {
  assert.equal(tabChosenOnOpen("s2 s1", "s1:t1,*t2 *s2:*u1"), "t2");
});

test("with one space the picker opens on the shown tab", () => {
  assert.equal(tabChosenOnOpen("s1", "*s1:t1,*t2"), "t2");
});

// Lists the spaces in the order the picker shows them: the record of the tab
// bar comes first, and then the spaces, as shots.js reads them.
function spacesInOrder(record, shot) {
  return recentSpaces(parseShot(shot), historyOf(record)).map((s) => s.id).join(" ");
}

// Gives the tab that the picker chooses when it opens, from the same values
// as spacesInOrder.
function tabChosenOnOpen(record, shot) {
  return String(openingTab(parseShot(shot), historyOf(record)));
}

function historyOf(record) {
  return record.split(" ").filter(Boolean);
}
