import assert from "node:assert/strict";
import { test } from "node:test";
import {
  agentList,
  agentsText,
  barStatuses,
  listKey,
  machineLabel,
  needsText,
  openingRow,
  stampChanges,
  timeText,
  untilNextMinute,
} from "../../../../herdr-app/mods/tab-bar/status.js";

const keys = (calls) => calls.map((k) => JSON.stringify(k)).join(" ");

test("shows the time as the tmux status line without the host", () => {
  assert.equal(timeText(new Date("2026-11-09T07:05:42")), "Mon 09/11/26 07:05");
});

test("counts every agent", () => {
  assert.equal(agentsText([{ status: "working" }, { status: "blocked" }]), "2 agents");
});

test("counts the agents that need you", () => {
  assert.equal(needsText([{ status: "blocked" }, { status: "working" }, { status: "blocked" }]), "· 2 needs you");
});

test("says nothing of needs while no agent is blocked", () => {
  assert.equal(needsText([{ status: "working" }, { status: "idle" }]), "");
});

test("a space on another machine shows that machine as a server", () => {
  assert.equal(JSON.stringify(machineLabel({ machine: "vps" }, "exegol")), '{"icon":"server","name":"vps"}');
});

test("a space on this computer shows its host name as a monitor", () => {
  assert.equal(JSON.stringify(machineLabel({ machine: null }, "exegol")), '{"icon":"monitor","name":"exegol"}');
});

test("this computer keeps the stock name while the host is not known", () => {
  assert.equal(JSON.stringify(machineLabel({ machine: null }, "")), '{"icon":"monitor","name":"This computer"}');
});

test("the agents keep the order of the app and take their place as their number", () => {
  const rows = agentList([{ address: "t3" }, { address: "t1" }, { address: "vps/t7" }]);
  assert.equal(rows.map((a) => `${a.address}=${a.number}`).join(" "), "t3=1 t1=2 vps/t7=3");
});

test("an agent after the ninth has no number because alt takes one digit", () => {
  const rows = agentList(Array.from({ length: 10 }, (_, i) => ({ address: `t${i}` })));
  assert.equal(rows.slice(8).map((a) => String(a.number)).join(" "), "9 null");
});

// A child row takes the address of its agent, so that a click on it goes to
// that agent. It has no number, because alt-N goes to agents only.
test("the records of an agent follow it as child rows with no number", () => {
  const rows = agentList([{ address: "t3" }, { address: "t1" }], { t3: { "sub/a": { state: "working", title: "Explore", msg: "find a" } } });
  assert.equal(
    rows.map((r) => `${r.address}=${r.number ?? "-"}` + (r.depth ? `,${r.depth},${r.status},${r.title},${r.msg}` : "")).join(" "),
    "t3=1 t3=-,1,working,Explore,find a t1=2",
  );
});

// In OSC 7501, the record sub/a/c is a child of the record sub/a.
test("a child record follows its parent record one level deeper", () => {
  const rows = agentList([{ address: "t3" }], { t3: { "sub/b": { title: "b" }, "sub/a/c": { title: "c" }, "sub/a": { title: "a" } } });
  assert.equal(rows.slice(1).map((r) => `${r.title}${r.depth}`).join(" "), "a1 c2 b1");
});

test("each row has a key of its own", () => {
  const rows = agentList([{ address: "t3" }], { t3: { "sub/a": {}, "sub/a/c": {} } });
  assert.equal(rows.map((r) => r.key).join(" "), "t3 t3:sub/a t3:sub/a/c");
});

test("the arrows move the chosen row and stop at the ends of the list", () => {
  assert.equal(
    keys([listKey("down", 0, [{}, {}]), listKey("down", 1, [{}, {}]), listKey("up", 1, [{}, {}]), listKey("up", 0, [{}, {}])]),
    '{"chosen":1} {"chosen":1} {"chosen":0} {"chosen":0}',
  );
});

// The search takes j and k as text.
test("ctrl j and ctrl k move the chosen row and j and k do not", () => {
  assert.equal(
    keys([listKey("ctrl-j", 0, [{}, {}]), listKey("ctrl-k", 1, [{}, {}]), listKey("j", 0, [{}, {}]), listKey("k", 1, [{}, {}])]),
    '{"chosen":1} {"chosen":0} null null',
  );
});

test("enter goes to the chosen row", () => {
  assert.equal(JSON.stringify(listKey("enter", 1, [{}, {}])), '{"go":1}');
});

// The search takes a digit as text. alt-N goes to agent N from anywhere.
test("a digit in the list is text for the search", () => {
  assert.equal(JSON.stringify(listKey("2", 0, [{ number: 1 }, { number: 2 }])), "null");
});

// A filter can leave no rows, and the next one must stay in reach.
test("tab and shift tab go to the next and the previous filter also on an empty list", () => {
  assert.equal(keys([listKey("tab", 0, []), listKey("shift-tab", 0, [{}])]), '{"filter":1} {"filter":-1}');
});

test("escape asks to clear the search or close also on an empty list", () => {
  assert.equal(JSON.stringify(listKey("escape", 0, [])), '{"escape":true}');
});

test("keys on an empty list do nothing", () => {
  assert.equal(keys([listKey("down", 0, []), listKey("enter", 0, [])]), "null null");
});

test("enter goes to the last row when the list shrank under the chosen row", () => {
  assert.equal(JSON.stringify(listKey("enter", 3, [{}, {}])), '{"go":1}');
});

test("the clock waits until the next minute starts", () => {
  assert.equal(untilNextMinute(new Date("2026-11-09T07:05:42.500")), 17500);
});

test("an agent seen first is stamped with its state and the time", () => {
  assert.equal(JSON.stringify(stampChanges({}, [{ address: "t1", status: "working" }], 5)), '{"t1":{"s":"working","at":5}}');
});

test("an agent that keeps its state keeps its stamp", () => {
  assert.equal(
    JSON.stringify(stampChanges({ t1: { s: "working", at: 5 } }, [{ address: "t1", status: "working" }], 9)),
    '{"t1":{"s":"working","at":5}}',
  );
});

// A look at a done agent turns it idle, and a look is not the agent doing
// anything. The stock sidebar counts the two as one state for this reason.
test("an agent that goes from done to idle keeps its stamp", () => {
  const done = stampChanges({}, [{ address: "t1", status: "done" }], 5);
  assert.equal(JSON.stringify(stampChanges(done, [{ address: "t1", status: "idle" }], 9)), '{"t1":{"s":"idle","at":5}}');
});

test("an agent that changes its state is stamped again", () => {
  assert.equal(
    JSON.stringify(stampChanges({ t1: { s: "working", at: 5 } }, [{ address: "t1", status: "blocked" }], 9)),
    '{"t1":{"s":"blocked","at":9}}',
  );
});

// The list is empty right after a start, so only age makes a stamp go.
test("the stamp of an agent that is gone goes after 30 days", () => {
  assert.equal(
    JSON.stringify(stampChanges({ old: { s: "idle", at: 0 }, new: { s: "idle", at: 2592000001 } }, [], 2592000002)),
    '{"new":{"s":"idle","at":2592000001}}',
  );
});

test("an agent still listed keeps a stamp older than 30 days", () => {
  assert.equal(
    JSON.stringify(stampChanges({ t1: { s: "idle", at: 0 } }, [{ address: "t1", status: "idle" }], 2592000002)),
    '{"t1":{"s":"idle","at":0}}',
  );
});

test("an agent row shows the time since its last change as the sidebar does", () => {
  const stamps = { a: { at: 9e9 - 59999 }, b: { at: 9e9 - 5 * 60000 }, c: { at: 9e9 - 150 * 60000 }, d: { at: 9e9 - 80 * 3600000 } };
  const rows = agentList(["a", "b", "c", "d"].map((address) => ({ address })), {}, stamps, 9e9);
  assert.equal(rows.map((a) => a.time).join(" "), "<1m 5m 2h 3d");
});

test("an agent row with no stamp shows no time", () => {
  assert.equal(agentList([{ address: "a" }], {}, {}, 9e9)[0].time, "");
});

// A subagent reports to its agent, so its done is no news, as in the stock
// sidebar.
test("a child record in error reads as blocked and a done one as idle", () => {
  const rows = agentList([{ address: "t3" }], { t3: { "sub/a": { state: "error" }, "sub/b": { state: "done" }, "sub/c": { state: "working" } } });
  assert.equal(rows.slice(1).map((r) => r.status).join(" "), "blocked idle working");
});

test("the agents come by focus recency and the agents never focused last in tab order", () => {
  const rows = agentList(["t1", "t2", "t3", "t4"].map((address) => ({ address })), {}, {}, 0, ["t3", "t1"]);
  assert.equal(rows.map((a) => a.address).join(" "), "t3 t1 t2 t4");
});

// alt-N goes to agent N in tab order, so the number of a row does not move
// with the focus.
test("an agent keeps the number of its place in tab order in the recency order", () => {
  const rows = agentList(["t1", "t2", "t3", "t4"].map((address) => ({ address })), {}, {}, 0, ["t3", "t1"]);
  assert.equal(rows.map((a) => `${a.address}=${a.number}`).join(" "), "t3=3 t1=1 t2=2 t4=4");
});

test("the child rows of an agent follow it in the recency order", () => {
  const rows = agentList([{ address: "t1" }, { address: "t2" }, { address: "t3" }], { t3: { "sub/a": {} } }, {}, 0, ["t3", "t1"]);
  assert.equal(rows.map((r) => r.key).join(" "), "t3 t3:sub/a t1 t2");
});

// So alt-a and then enter goes back to the agent before, as the recent picker
// does with the space before.
test("the list opens on the agent focused before the focused agent", () => {
  assert.equal(openingRow([{ address: "t1", focused: true }, { depth: 1 }, { address: "t2" }]), 2);
});

// With the focus on a pane with no agent, the agent focused last is the one
// before.
test("the list opens on the first agent while no agent has the focus", () => {
  assert.equal(openingRow([{ address: "t1" }, { address: "t2" }]), 0);
});

test("the list opens on the focused agent when it is the only agent", () => {
  assert.equal(openingRow([{ address: "t1", focused: true }, { depth: 1 }]), 0);
});

// The order is that of the stock sidebar. The list shows each agent.
test("the bar shows only the statuses that an agent has", () => {
  assert.equal(barStatuses(["idle", "working"].map((status) => ({ status }))).join(" "), "working");
});

test("the bar shows each status once blocked then done then working and no idle", () => {
  const statuses = ["working", "idle", "done", "working", "blocked", "done"].map((status) => ({ status }));
  assert.equal(barStatuses(statuses).join(" "), "blocked done working");
});
