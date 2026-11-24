import assert from "node:assert/strict";
import { test } from "node:test";
import { nextMove, numberTabs, swapNumbers, tabNumbered } from "../../../../herdr-app/mods/tab-bar/numbers.js";
import { parseShot } from "../shots.js";

test("tabs seen first take their position as their number", () => {
  assert.equal(numbersAfter("*s1:*t1,t2,t3"), "t1=1 t2=2 t3=3");
});

test("a tab keeps its number when a tab before it closes", () => {
  assert.equal(numbersAfter("*s1:*t1,t2,t3", "*s1:*t1,t3"), "t1=1 t3=3");
});

test("a new tab takes the lowest free number", () => {
  assert.equal(numbersAfter("*s1:*t1,t2,t3", "*s1:*t1,t3", "*s1:t1,t3,*t4"), "t1=1 t3=3 t4=2");
});

test("with no free number a new tab takes the next one", () => {
  assert.equal(numbersAfter("*s1:*t1,t2,t3", "*s1:*t1,t3", "*s1:t1,t3,*t4", "*s1:t1,t3,t4,*t5"), "t1=1 t3=3 t4=2 t5=4");
});

test("a space out of sight while the layout loads keeps its numbers", () => {
  assert.equal(numbersAfter("*s1:*t1,t2,t3", "*s1:*t1,t3", "", "*s1:*t1,t3"), "t1=1 t3=3");
});

test("a new tab moves between the tabs with the numbers around its own", () => {
  assert.equal(moveAfter("*s1:*t1,t2,t3", "*s1:*t1,t3", "*s1:t1,t3,*t4"), "t4 2");
});

test("tabs in number order stay where they are", () => {
  assert.equal(moveAfter("*s1:*t1,t2,t3", "*s1:*t1,t3"), "null");
});

test("swapping left trades numbers with the tab before", () => {
  assert.equal(numbersAfterSwap(-1, "*s1:*t1,t2,t3", "*s1:t1,*t3"), "t1=3 t3=1");
});

test("swapping left from the first tab trades numbers with the last tab", () => {
  assert.equal(numbersAfterSwap(-1, "*s1:*t1,t2,t3"), "t1=3 t2=2 t3=1");
});

test("swapping right from the last tab trades numbers with the first tab", () => {
  assert.equal(numbersAfterSwap(1, "*s1:t1,t2,*t3"), "t1=3 t2=2 t3=1");
});

test("a number selects the tab that holds it and not the tab at that place", () => {
  assert.equal(tabNumberedAfter(3, "*s1:*t1,t2,t3", "*s1:*t1,t3"), "t3");
});

test("a number no tab holds selects nothing", () => {
  assert.equal(tabNumberedAfter(2, "*s1:*t1,t2,t3", "*s1:*t1,t3"), "null");
});

// Shows each shot to the numbers in turn, and gives the number of each tab of
// the shown space after the last one, in its order. A shot lists the spaces,
// as in "*s1:t1,*t2 s2:*u1": a star marks the shown space, and the tab that a
// space shows. An empty shot shows no space.
function numbersAfter(...shots) {
  const { record, space } = shown(shots);
  return numbersOf(record, space);
}

// Gives the tab that must move to put the shown space in number order, and
// the place it moves to, or null.
function moveAfter(...shots) {
  const { record, space } = shown(shots);
  const move = nextMove(record, space);
  return move ? `${move.id} ${move.index}` : "null";
}

// Swaps the shown tab with the tab that many places away, and gives the
// numbers as numbersAfter does.
function numbersAfterSwap(places, ...shots) {
  const { record, space } = shown(shots);
  return numbersOf(swapNumbers(record, space, places), space);
}

// Gives the tab of the shown space that holds the number, or null.
function tabNumberedAfter(number, ...shots) {
  const { record, space } = shown(shots);
  return String(tabNumbered(record, space, number));
}

function shown(shots) {
  const parsed = shots.map(parseShot);
  const record = parsed.reduce((seen, shot) => numberTabs(seen, shot), {});
  return { record, space: parsed.at(-1).find((s) => s.active) };
}

function numbersOf(record, space) {
  return space.tabs.map((t) => `${t.id}=${record[space.id]?.[t.id]}`).join(" ");
}
