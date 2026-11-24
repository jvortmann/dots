import assert from "node:assert/strict";
import { test } from "node:test";
import { lastTab, observeAgents, observeSpaces, observeTabs, tabToReturnTo } from "../../../../herdr-app/mods/tab-bar/history.js";
import { parseShot } from "../shots.js";

test("after a switch the last tab is the tab shown before", () => {
  assert.equal(lastTabAfter("*s1:*t1,t2", "*s1:t1,*t2"), "t1");
});

test("going back to the last tab makes the tab left the last tab", () => {
  assert.equal(lastTabAfter("*s1:*t1,t2", "*s1:t1,*t2", "*s1:*t1,t2"), "t2");
});

test("each space keeps its own last tab", () => {
  assert.equal(
    lastTabAfter("*s1:*t1,t2 s2:*u1,u2", "*s1:t1,*t2 s2:*u1,u2", "s1:t1,*t2 *s2:*u1,u2", "s1:t1,*t2 *s2:u1,*u2", "*s1:t1,*t2 s2:u1,*u2"),
    "t1",
  );
});

test("a closed tab is no longer the last tab", () => {
  assert.equal(lastTabAfter("*s1:*t1,t2", "*s1:t1,*t2", "*s1:*t1"), "null");
});

test("after the shown tab closes the bar shows the tab shown before it", () => {
  assert.equal(tabShownAfterClose("*s1:*t1,t2,t3", "*s1:t1,t2,*t3", "*s1:t1,*t2"), "t1");
});

test("a second close goes back to the tab shown before the first one", () => {
  assert.equal(
    tabShownAfterClose("*s1:*t1,t2,t3,t4", "*s1:t1,*t2,t3,t4", "*s1:t1,t2,*t3,t4", "*s1:t1,t2,*t4", "*s1:t1,*t2,t4", "*s1:t1,*t4"),
    "t1",
  );
});

test("a switch with no close selects no other tab", () => {
  assert.equal(tabShownAfterClose("*s1:*t1,t2,t3", "*s1:t1,*t2,t3", "*s1:t1,t2,*t3"), "null");
});

test("a switch to a space whose shown tab closed meanwhile selects no other tab", () => {
  assert.equal(
    tabShownAfterClose(
      "*s1:*t1,t2,t3 s2:*u1",
      "*s1:t1,*t2,t3 s2:*u1",
      "*s1:t1,t2,*t3 s2:*u1",
      "s1:t1,t2,*t3 *s2:*u1",
      "s1:t1,*t2 *s2:*u1",
      "*s1:*t1,t2 s2:*u1",
    ),
    "null",
  );
});

test("after the bar goes back the last tab is not the tab the app showed", () => {
  assert.equal(lastTabAfter("*s1:*t1,t2,t3,t4", "*s1:t1,*t2,t3,t4", "*s1:t1,t2,*t3,t4", "*s1:t1,t2,*t4", "*s1:t1,*t2,t4"), "t1");
});

test("the record forgets a closed space", () => {
  assert.equal(spacesInRecordAfter("*s1:*t1 s2:*u1", "s1:*t1 *s2:*u1", "*s1:*t1"), "s1");
});

test("the spaces go from the shown space to the space shown longest ago", () => {
  assert.equal(spacesByRecencyAfter("*s1:*t1 s2:*u1 s3:*v1", "s1:*t1 s2:*u1 *s3:*v1", "s1:*t1 *s2:*u1 s3:*v1"), "s2 s3 s1");
});

test("the space history forgets a closed space", () => {
  assert.equal(spacesByRecencyAfter("*s1:*t1 s2:*u1", "s1:*t1 *s2:*u1", "*s1:*t1"), "s1");
});

test("the agents go from the agent focused last to the agent focused longest ago", () => {
  assert.equal(agentsByRecencyAfter("*t1 t2", "t1 *t2"), "t2 t1");
});

test("an agent that gets the focus again moves to the front once", () => {
  assert.equal(agentsByRecencyAfter("*t1 t2", "t1 *t2", "*t1 t2"), "t1 t2");
});

test("focus on a pane with no agent keeps the agent history", () => {
  assert.equal(agentsByRecencyAfter("*t1 t2", "t1 *t2", "t1 t2"), "t2 t1");
});

// The history drops the oldest id, so it cannot grow without bound.
test("the agent history keeps the 30 agents focused last", () => {
  const seen = agentsByRecencyAfter(...Array.from({ length: 31 }, (_, i) => `*t${i + 1}`)).split(" ");
  assert.equal(`${seen.length} ${seen[0]} ${seen.at(-1)}`, "30 t31 t2");
});

// Shows each shot to the history in turn, and gives the last tab of the shown
// space after the last one, or null. A shot lists the spaces, as in
// "*s1:t1,*t2 s2:*u1": a star marks the shown space, and the tab that a space
// shows.
function lastTabAfter(...shots) {
  const { history, last } = observed(shots);
  return String(lastTab(history, last));
}

// Gives the tab that the bar selects after the last shot, or null.
function tabShownAfterClose(...shots) {
  const { history, last } = observed(shots);
  return String(tabToReturnTo(history, last));
}

// Gives the spaces that the record keeps.
function spacesInRecordAfter(...shots) {
  return Object.keys(observed(shots).history).join(" ");
}

// Shows each shot to the space history in turn, and gives its spaces.
function spacesByRecencyAfter(...shots) {
  return shots.map(parseShot).reduce((seen, shot) => observeSpaces(seen, shot), []).join(" ");
}

// Shows each shot to the agent history in turn, and gives its agents. A shot
// lists the agents, as in "t1 *t2": a star marks the focused agent.
function agentsByRecencyAfter(...shots) {
  const parsed = shots.map((shot) => shot.split(" ").map((a) => ({ address: a.replace("*", ""), focused: a.startsWith("*") })));
  return parsed.reduce((seen, shot) => observeAgents(seen, shot), []).join(" ");
}

function observed(shots) {
  const parsed = shots.map(parseShot);
  return { history: parsed.reduce((seen, shot) => observeTabs(seen, shot), {}), last: parsed.at(-1) };
}
