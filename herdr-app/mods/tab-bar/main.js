// The bar at the bottom of the layout: space picker, tabs, status, and window
// controls. The status is the agent count with one mark for each status except
// idle, then the agents that need you, the Changes button, the machine label and
// the time. A click on the count opens the agent list above it, and so does alt-a
// (tab-bar.agents). A click on the Changes button shows or hides the changes panel.
// In the open list, alt-a closes it: keys.json runs overlay.close for mod:tab-bar,
// because the list has the keyboard. Typed text searches the list, ctrl-j and
// ctrl-k move like the arrows, and Tab and shift-Tab change the filter tab. Esc
// clears the search, and with no search it closes the list. In keys.json,
// alt-l, alt-n, alt-w and alt-d pick All, Needs you, Working and Done, and the
// key of the active filter goes back to All.
// The list puts the agents in focus order, the focused agent first, and it opens
// on the agent focused before. select-agent-N (alt-1..9) goes to agent N in tab
// order, which is the number that its row shows.
//
// A key has no position, so the count keeps its place from the pointer, a press
// or a move over it. It stores the place in shared state, as distances from the
// right and bottom edges of the window. Before the pointer has been there, the
// list opens at the pointer.
//
// The bar runs last-tab (ctrl-a ctrl-a), which selects the tab shown before.
// When the shown tab closes, the bar selects the tab shown before it, and not
// the tab beside it that the app shows.
// The bar runs swap-theme (ctrl-a t), the zsh function that swaps the light and
// dark themes. A key action cannot run a program, so the bar runs it for the key.
// Each tab keeps its number, as in tmux: the bar numbers each new tab and moves
// it into number order, and select-N selects by number.
//
// The agent list shows the subagents of each agent under it, from the child
// records. Only the open list reads them, with `hc get` every 2 seconds,
// because terminals() and agents() do not carry them. It keeps them in shared
// state, so that the bar can size the list. A popup cannot change its size, so
// the list opens again in place when its height changes.

import { View, div, svg } from "gpui-kit";
import { h_flex, v_flex, InputState } from "gpui-base";
import { spaces, panes, agents, terminals, run, theme, openOverlay, closeOverlay, props, window as win, shared, setShared, nextCommand, notify, exec, hc, checking, appHome, readTextFile, writeTextFile, layout } from "herdr";
import { tabText } from "./label.js";
import { agentHead, agentRows, ROW, HEAD } from "./agent-list.js";
import { filterRows, filterCounts, nextFilter, pickedFilter, filterOfCommand, rowOf } from "./search.js";
import { agentsText, needsText, barStatuses, agentList, openingRow, listKey, machineLabel, timeText, untilNextMinute, stampChanges } from "./status.js";
import { observeTabs, observeSpaces, observeAgents, lastTab, tabToReturnTo } from "./history.js";
import { programIcon } from "./program-icon.js";
import { barMark } from "./status-mark.js";
import { alpha } from "./alpha.js";
import { lead } from "./lead.js";
import { numberTabs, nextMove, swapNumbers, tabNumbered } from "./numbers.js";
import { PI_ICON, syncPiIcon } from "./pi-icon.js";
import { changesShown, toggleChanges } from "./changes-panel.js";

// Shared state, not a field: another layout, a save or a restart starts the mod fresh.
const HISTORY = "tab-bar.tab-history";
const NUMBERS = "tab-bar.tab-numbers";
const SPACES = "tab-bar.space-history";
const AGENTS = "tab-bar.agent-history";
const RECORDS = "tab-bar.agent-records";
const COUNT_AT = "tab-bar.count-at";
// In localStorage, so the times of the agent list outlive a restart.
const CHANGES = "agent-changes";
const LIST_WIDTH = 400;

function colors(t) {
  return {
    // The shown tab has a fill, an edge and bright text; a hovered tab gets only bright text.
    tab: t.surface,
    tabEdge: alpha(t.border, 1 / 4),
    edge: t.border,
    chip: t.chrome,
    text: t.foreground,
    label: t.muted,
    dim: t.dim,
  };
}

// The machine label of the stock workspace-status mod, with the host name as
// its text. A click opens the stock Add machine dialog, like the row of the
// stock sidebar footer.
function machine(C, { icon, name }) {
  return own(h_flex())
    .id("tm-machine")
    .gap(6)
    .items_center()
    .cursor_pointer()
    .hover((s) => s.text_color(C.text))
    .on_click(() => run("mod.open", { name: "machine-add" }))
    .child(svg(`mods/workspace-chrome/${icon}.svg`).size(13))
    .child(name);
}

// The stock panel button. The stock tabs mod shows it only when the shared
// workspace.panels lists "changes". This bar always shows it.
function changesButton(C, shown) {
  return own(h_flex())
    .id("tm-changes")
    .gap(6)
    .items_center()
    .cursor_pointer()
    .hover((s) => s.text_color(C.text))
    .when(shown, (el) => el.text_color(C.text))
    .on_click(() => toggleChanges(layout()).forEach(([command, args]) => run(command, args)))
    .child(svg("mods/changes/changes.svg").size(14))
    .child("Changes");
}

// A control in the draggable bar: the press is its own, not the window's
// (a right press there would open the system's window menu).
function own(el, press = () => {}) {
  return el
    .on_mouse_down("left", (e, cx) => {
      press(e);
      cx.stop_propagation();
    }).on_mouse_down("right", (_e, cx) => cx.stop_propagation());
}

// The anchor holds the left edge and the bottom edge of the list, above the agent count.
function openList(anchor, count, chosen = 0, state = {}) {
  const height = listHeight(count);
  openOverlay({
    mod: "tab-bar",
    kind: "popup",
    width: LIST_WIDTH,
    height,
    props: { popup: "agents", anchor, height, chosen, ...state },
    at: anchor ? { x: anchor.x, y: anchor.bottom - height } : "pointer",
  });
}

function changesOf() {
  try {
    const changes = JSON.parse(localStorage.getItem(CHANGES) ?? "{}");
    return changes && typeof changes === "object" && !Array.isArray(changes) ? changes : {};
  } catch {
    return {};
  }
}

function listHeight(count) {
  return 8 + HEAD + Math.min(Math.max(count, 1), 12) * ROW;
}

// The child records of a terminal, as OSC 7501 reports them.
async function recordsOf(address) {
  try {
    return JSON.parse((await hc(["get", address, "--json"])).stdout).records ?? {};
  } catch {
    return {};
  }
}

function windowButton(C, id, icon, command) {
  return own(
    div()
      .id(id)
      .flex_none()
      .w(24)
      .h(24)
      .rounded_full()
      .flex()
      .items_center()
      .justify_center()
      .bg(C.chip)
      .text_color(C.dim)
      .cursor_pointer()
      .hover((s) => s.bg(C.edge).text_color(C.text))
      .on_click(() => run(command))
      .child(svg(`mods/tab-bar/${icon}.svg`).size(14)),
  );
}

export default class TerminalsBar extends View {
  // The list is this mod opened as a popup, and a command reaches every shown
  // copy, so the list copy takes only its filter commands, or a swap runs twice.
  init(_props, cx) {
    if (props()?.popup) return this.initList(cx);
    this.host = "";
    if (!checking()) cx.spawn(async (cx) => {
      try {
        this.host = (await exec("hostname", ["-s"])).stdout.trim();
        cx.notify();
      } catch {
        // Without the host, the machine label shows "This computer".
      }
    });
    this.tick(cx);
    cx.spawn(async () => {
      for (;;) {
        const command = await nextCommand();
        if (command === "last-tab") this.selectLastTab();
        else if (command === "swap-left") this.swap(-1);
        else if (command === "swap-right") this.swap(1);
        else if (command === "agents") this.openAgents();
        else if (command === "swap-theme") await this.swapTheme();
        else if (command.startsWith("select-agent-")) this.selectAgent(Number(command.slice("select-agent-".length)));
        else if (command.startsWith("select-")) this.selectNumber(Number(command.slice("select-".length)));
      }
    });
  }

  initList(cx) {
    this.listing = true;
    this.chosen = props().chosen ?? 0;
    this.records = shared(RECORDS) ?? {};
    this.query = props().query ?? "";
    this.filter = props().filter ?? "all";
    this.prefer = props().prefer ?? null;
    this.input = InputState.new({ placeholder: "Search agents", value: this.query });
    this.input.on("change", (_e, cx) => this.search(this.input.value(), cx));
    this.input.on("submit", () => this.goChosen());
    this.input.focus();
    cx.timer.after(600, () => this.input.focus());
    this.handle = cx.focus_handle();
    cx.spawn(async (cx) => {
      for (;;) {
        const wanted = filterOfCommand(await nextCommand());
        if (wanted) this.pickFilter(pickedFilter(this.filter, wanted), cx);
      }
    });
    if (!checking()) cx.timer.every(2000, (cx) => this.readRecords(cx));
    if (!checking()) this.readRecords(cx);
  }

  readRecords(cx) {
    if (this.reading) return;
    this.reading = true;
    cx.spawn(async (cx) => {
      const records = Object.fromEntries(await Promise.all(agents().map(async (a) => [a.address, await recordsOf(a.address)])));
      this.records = records;
      if (JSON.stringify(records) !== JSON.stringify(shared(RECORDS))) setShared(RECORDS, records);
      const { anchor, height, overlay } = props();
      const count = agentList(agents(), records).length;
      if (anchor && listHeight(count) !== height) {
        closeOverlay(overlay);
        openList(anchor, count, this.chosen, { query: this.query, filter: this.filter, prefer: this.prefer });
        return;
      }
      this.reading = false;
      cx.notify();
    });
  }

  allRows() {
    return agentList(agents(), this.records, changesOf(), Date.now(), shared(AGENTS) ?? []);
  }

  renderList() {
    const t = theme();
    const all = this.allRows();
    const rows = filterRows(all, this.filter, this.query);
    return v_flex()
      .id("tm-agent-list")
      .size_full()
      .bg(t.canvas)
      .track_focus(this.handle)
      .on_key_down((e, cx) => this.listKeyDown(e, rows, cx))
      .child(agentHead(t, this.input, this.filter, filterCounts(all, this.query), (f, cx) => this.pickFilter(f, cx)))
      .child(agentRows(t, rows, Math.min(this.chosen, rows.length - 1), (a) => this.goTo(a), all.length ? "No matches" : "No agents").h(props().height - HEAD));
  }

  pickFilter(filter, cx) {
    this.filter = filter;
    this.choose();
    cx.notify();
  }

  search(query, cx) {
    this.query = query;
    this.choose();
    cx.notify();
  }

  clearSearch(cx) {
    this.input.set_value("");
    this.search("", cx);
  }

  choose() {
    this.chosen = rowOf(this.shownRows(), this.prefer);
  }

  shownRows() {
    return filterRows(this.allRows(), this.filter, this.query);
  }

  listKeyDown(e, rows, cx) {
    const key = listKey(e.keystroke, this.chosen, rows);
    if (!key) return;
    cx.stop_propagation();
    if ("filter" in key) return this.pickFilter(nextFilter(this.filter, key.filter), cx);
    if ("escape" in key) return this.query ? this.clearSearch(cx) : closeOverlay(props().overlay);
    if ("go" in key) {
      if (rows[key.go]) this.goTo(rows[key.go]);
      return;
    }
    this.chosen = key.chosen;
    cx.notify();
  }

  goChosen() {
    const rows = this.shownRows();
    const a = rows[Math.min(this.chosen, rows.length - 1)];
    if (a) this.goTo(a);
  }

  goTo(a) {
    if (this.gone) return;
    this.gone = true;
    closeOverlay(props().overlay);
    run("agent.focus", { terminal: a.address });
  }

  tick(cx) {
    cx.timer.after(untilNextMinute(new Date()), (cx) => {
      cx.notify();
      this.tick(cx);
    });
  }

  async swapTheme() {
    try {
      const swapped = await exec("zsh", ["-c", "source ~/.dots/zsh/conf/plugins/theme.zsh; swap-theme"], { timeout: 5000 });
      if (swapped.code !== 0) throw new Error(swapped.stderr.trim() || `swap-theme exited with code ${swapped.code}`);
    } catch (error) {
      notify({ title: "Theme swap failed", body: String(error?.message ?? error), level: "error" });
    }
  }

  selectLastTab() {
    const id = lastTab(this.observe(), spaces());
    if (id) run("tab.select", { id });
    else notify({ title: "No previous tab", level: "info" });
  }

  // After the shown tab closes, the app shows the tab beside it. The bar then
  // selects the tab shown before the closed tab, as tmux does.
  returnAfterClose(history) {
    const id = tabToReturnTo(history, spaces());
    if (id) run("tab.select", { id });
  }

  selectNumber(number) {
    const space = spaces().find((s) => s.active);
    const id = space && tabNumbered(this.number(), space, number);
    if (id) run("tab.select", { id });
  }

  selectAgent(number) {
    const agent = agentList(agents()).find((a) => a.number === number);
    if (agent) run("agent.focus", { terminal: agent.address });
  }

  openAgents() {
    const at = shared(COUNT_AT);
    const { width, height } = window.viewport_size();
    const rows = agentList(agents(), shared(RECORDS) ?? {}, {}, 0, shared(AGENTS) ?? []);
    const chosen = openingRow(rows);
    openList(at && { x: width - at.right - LIST_WIDTH, bottom: height - at.bottom - 6 }, rows.length, chosen, { prefer: rows[chosen]?.key ?? null });
  }

  placeCount(bounds) {
    if (!bounds) return;
    const { width, height } = window.viewport_size();
    const at = { right: Math.round(width - bounds.x - bounds.width), bottom: Math.round(height - bounds.y) };
    if (JSON.stringify(at) !== JSON.stringify(shared(COUNT_AT))) setShared(COUNT_AT, at);
  }

  // The tabs trade numbers, and the next render trades their places.
  swap(by) {
    const space = spaces().find((s) => s.active);
    if (space?.tabs.some((t) => t.active)) setShared(NUMBERS, swapNumbers(this.number(), space, by));
  }

  number() {
    const before = shared(NUMBERS) ?? {};
    const after = numberTabs(before, spaces());
    if (JSON.stringify(after) !== JSON.stringify(before)) setShared(NUMBERS, after);
    return after;
  }

  // One move for each render: the move renders again, and that render takes
  // the next one. A move that changed nothing is not sent again. The shown
  // space goes first, so a space that cannot move does not block it.
  place(numbers) {
    const all = spaces();
    const move = [...all].sort((a, b) => b.active - a.active).map((s) => nextMove(numbers, s)).find(Boolean);
    if (!move) {
      this.placed = null;
      return;
    }
    const order = JSON.stringify([move, all.map((s) => s.tabs.map((t) => t.id))]);
    if (order === this.placed) return;
    this.placed = order;
    run("tab.move", move);
  }

  observe() {
    const before = shared(HISTORY) ?? {};
    const after = observeTabs(before, spaces());
    if (JSON.stringify(after) !== JSON.stringify(before)) setShared(HISTORY, after);
    const seen = shared(SPACES) ?? [];
    const recent = observeSpaces(seen, spaces());
    if (JSON.stringify(recent) !== JSON.stringify(seen)) setShared(SPACES, recent);
    const focusedBefore = shared(AGENTS) ?? [];
    const byFocus = observeAgents(focusedBefore, agents());
    if (JSON.stringify(byFocus) !== JSON.stringify(focusedBefore)) setShared(AGENTS, byFocus);
    return after;
  }

  // The bar stamps each change of state in its own storage, because a mod
  // cannot read the storage of the sidebar. The agent list shows the time
  // since the stamp.
  stamp(list) {
    const before = changesOf();
    const after = stampChanges(before, list, Date.now());
    if (JSON.stringify(after) !== JSON.stringify(before)) localStorage.setItem(CHANGES, JSON.stringify(after));
  }

  // The app does not tint the pi icon of programs.json, because it is a
  // picture. So the bar writes the file in color 13 of the theme when that
  // color changes. Every mod then shows the new icon, and the app loads
  // this mod again.
  paintPi(cx, color) {
    if (checking() || color === this.piColor) return;
    this.piColor = color;
    cx.spawn(async () => {
      try {
        await syncPiIcon({ readTextFile, writeTextFile }, `${appHome()}/${PI_ICON}`, color);
      } catch (error) {
        notify({ title: "Pi icon", body: String(error?.message ?? error), level: "error" });
      }
    });
  }

  render(cx) {
    if (this.listing) return this.renderList();
    this.returnAfterClose(this.observe());
    const numbers = this.number();
    this.place(numbers);
    const t = theme();
    this.paintPi(cx, t.ansi13);
    const C = colors(t);
    const space = spaces().find((p) => p.active);
    if (!space) return div();
    const all = panes();
    const w = win() ?? {};
    const records = terminals();
    const list = agents();
    this.stamp(list);

    const tab = (c) => {
      const p = lead(all, c.id);
      const record = p?.terminal ? records.find((r) => r.address === p.terminal) : undefined;
      const text = tabText(c, record);
      return own(h_flex())
        .id(`tm-${c.id}`)
        .flex_shrink(1)
        .max_w(220)
        .min_w(0)
        .h_full()
        .pl(8)
        .pr(8)
        .gap(6)
        .items_center()
        .rounded(4)
        .cursor_pointer()
        .text_size(13)
        .text_color(C.label)
        .when(c.active, (el) =>
          el.pl(7).pr(7).bg(C.tab).border_1().border_color(C.tabEdge).text_color(C.text),
        )
        .when(!c.active, (el) => el.hover((s) => s.text_color(C.text)))
        .on_click(() => run("tab.select", { id: c.id }))
        .on_mouse_down("right", () =>
          openOverlay({ mod: "menu", kind: "popup", width: 200, props: { tab: "tab", target: { id: c.id, space: space.id } } }),
        )
        .child(div().flex_none().text_color(C.label).child(`${numbers[space.id][c.id]}`))
        .child(programIcon(t, p, p?.status))
        .child(
          h_flex()
            .min_w(0)
            .truncate()
            .when(Boolean(text), (el) => el.child(div().truncate().child(text))),
        );
    };

    return h_flex()
      .size_full()
      .gap(8)
      .items_center()
      .child(
        h_flex()
          .flex_shrink(1)
          .min_w(0)
          .h_full()
          .items_center()
          .child(
            own(h_flex())
              .id("tm-space")
              .flex_none()
              .h_full()
              .pl(10)
              .pr(12)
              .gap(8)
              .items_center()
              .rounded(2)
              .bg(C.chip)
              .cursor_pointer()
              .text_size(13)
              .text_color(C.dim)
              .hover((s) => s.text_color(C.text))
              .on_click(() => run("mod.open", { name: "recent-picker" }))
              .child(svg("mods/tab-bar/stack.svg").size(15))
              .child(div().max_w(160).truncate().text_color(C.text).child(space.name)),
          )
          .child(
            h_flex()
              .flex_shrink(1)
              .min_w(0)
              .h_full()
              .gap(3)
              .children(space.tabs.map(tab)),
          ),
      )
      .child(div().flex_1())
      .child(
        h_flex()
          .flex_none()
          .pl(4)
          .pr(8)
          .gap(12)
          .items_center()
          .text_size(13)
          .text_color(C.label)
          .child(
            own(h_flex(), (e) => this.placeCount(e.bounds))
              .id("tm-agents")
              .gap(6)
              .items_center()
              .cursor_pointer()
              .hover((s) => s.text_color(C.text))
              .on_click(() => this.openAgents())
              .on_mouse_move((e) => this.placeCount(e.bounds))
              .child(svg("mods/tab-bar/agent.svg").size(14))
              .child(agentsText(list))
              .child(h_flex().children(barStatuses(list).map((status) => barMark(t, status))))
              .when(Boolean(needsText(list)), (el) => el.child(div().text_color(t.blocked).child(needsText(list)))),
          )
          .child(changesButton(C, changesShown(layout())))
          .child(machine(C, machineLabel(space, this.host)))
          .child(timeText(new Date())),
      )
      .when(Boolean(w.buttons), (el) =>
        el.child(
          h_flex()
            .flex_none()
            .pl(6)
            .pr(4)
            .gap(8)
            .child(windowButton(C, "tm-min", "win-min", "window.minimize"))
            .child(windowButton(C, "tm-max", w.maximized ? "win-restore" : "win-max", "window.maximize"))
            .child(windowButton(C, "tm-close", "win-close", "window.close")),
        ),
      );
  }
}
