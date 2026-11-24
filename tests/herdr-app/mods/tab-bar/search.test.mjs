import assert from "node:assert/strict";
import { test } from "node:test";
import { filterCounts, filterOfCommand, filterRows, nextFilter, pickedFilter, rowOf } from "../../../../herdr-app/mods/tab-bar/search.js";

// Rows as agentList gives them: each agent, then its child rows.
const rows = [
  { key: "t1", address: "t1", status: "blocked", space_name: "dots", tab_name: "api", program: { name: "Claude" }, title: "Fix login" },
  { key: "t1:sub/a", address: "t1", depth: 1, status: "working", title: "Explore", msg: "find the router" },
  { key: "t2", address: "t2", status: "working", space_name: "web", tab_name: "ui", program: { name: "pi" }, title: "Style the bar" },
  { key: "t3", address: "t3", status: "idle", space_name: "notes", tab_name: "2", program: { name: "Codex" }, title: "" },
  { key: "t4", address: "t4", status: "done", space_name: "dots", tab_name: "docs", program: { name: "pi" }, title: "Write the plan" },
];

const keysOf = (found) => found.map((r) => r.key).join(" ");

test("the needs you filter keeps only the agents that need you", () => {
  assert.equal(keysOf(filterRows(rows, "blocked", "")), "t1 t1:sub/a");
});

test("all shows every row and the idle agents too", () => {
  assert.equal(keysOf(filterRows(rows, "all", "")), "t1 t1:sub/a t2 t3 t4");
});

test("a child row goes with the status of its agent and not its own", () => {
  assert.equal(keysOf(filterRows(rows, "working", "")), "t2");
});

test("the search matches the space the tab the program and the title in any case", () => {
  assert.equal(["notes", "UI", "codex", "Plan"].map((q) => keysOf(filterRows(rows, "all", q))).join("|"), "t3|t2|t3|t4");
});

test("a match on the type or description of a child row keeps its agent shown", () => {
  assert.equal(["explore", "router"].map((q) => keysOf(filterRows(rows, "all", q))).join("|"), "t1 t1:sub/a|t1 t1:sub/a");
});

// The counts follow the search, so a tab says where the matches are.
test("each filter counts its agents that match the search", () => {
  const counts = ["", "dots"].map((q) => {
    const c = filterCounts(rows, q);
    return [c.all, c.blocked, c.working, c.done].join(" ");
  });
  assert.equal(counts.join("|"), "4 1 1 1|2 1 0 1");
});

test("the next filter goes round both ways", () => {
  assert.equal([nextFilter("all", 1), nextFilter("all", -1), nextFilter("done", 1)].join(" "), "blocked done all");
});

test("the chosen row is the agent chosen at the start while it shows or else the first", () => {
  assert.equal([rowOf(filterRows(rows, "all", ""), "t2"), rowOf(filterRows(rows, "blocked", ""), "t2")].join(" "), "2 0");
});

test("the key of a filter picks it and the key of the active filter goes back to all", () => {
  assert.equal([pickedFilter("all", "done"), pickedFilter("done", "done"), pickedFilter("all", "all")].join(" "), "done all all");
});

test("a filter command names its filter and another command names none", () => {
  const named = [filterOfCommand("filter-done"), filterOfCommand("filter-blocked"), filterOfCommand("filter-idle"), filterOfCommand("swap-left")];
  assert.equal(named.map(String).join(" "), "done blocked null null");
});
