// The bar at the bottom of the layout: space picker, tabs, status, and window
// controls. The status is the agent count with a dot for each agent that is not
// idle, then the agents that need you, the machine label and the time. A click
// on the count opens the agent list above it. select-agent-N (alt-1..9) goes
// to agent N of that list. The bar runs last-tab (ctrl-a ctrl-a), which selects
// the tab shown before. Each tab keeps its number, as in tmux: the bar numbers
// each new tab and moves it into number order, and select-N selects by number.

import { View, div, svg, image } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, panes, agents, terminals, run, theme, openOverlay, closeOverlay, props, window as win, shared, setShared, nextCommand, notify, exec, checking } from "herdr";
import { tabText } from "./label.js";
import { agentRows, ROW } from "./agent-list.js";
import { agentsText, needsText, agentList, listKey, machineLabel, timeText, untilNextMinute } from "./status.js";
import { observeTabs, lastTab } from "./history.js";
import { numberTabs, nextMove, swapNumbers, tabNumbered } from "./numbers.js";

// Shared state, not a field: another layout, a save or a restart starts the mod fresh.
const HISTORY = "tab-bar.tab-history";
const NUMBERS = "tab-bar.tab-numbers";
const LIST_WIDTH = 360;

function colors(t) {
  return {
    // The shown tab has a fill, an edge and bright text; a hovered tab gets only bright text.
    tab: t.surface,
    tabEdge: `${t.border}40`,
    edge: t.border,
    chip: t.chrome,
    text: t.foreground,
    label: t.muted,
    dim: t.dim,
  };
}

// The pane a tab's tab speaks for: the focused one, else its agent, else the first.
function lead(all, id) {
  const mine = all.filter((p) => p.tab === id);
  return mine.find((p) => p.focused) ?? mine.find((p) => p.program?.agent) ?? mine[0];
}

// The program's icon from the app's table: its glyph in its color, or its logo.
function programIcon(t, C, p) {
  const g = p?.program;
  const dot = p?.status && p.status !== "idle" ? t[p.status] : null;
  return div()
    .relative()
    .flex_none()
    .w(14)
    .h(14)
    .flex()
    .items_center()
    .justify_center()
    .when(Boolean(g?.icon), (el) =>
      el.child(g.tint ? svg(g.icon).size(14).text_color(g.color ?? C.text) : image(g.icon).w(14).h(14)),
    )
    .when(Boolean(dot), (el) => el.child(div().absolute().top(-2).right(-2).w(7).h(7).rounded_full().bg(dot)));
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

// A control in the draggable bar: the press is its own, not the window's
// (a right press there would open the system's window menu).
function own(el, press = () => {}) {
  return el
    .on_mouse_down("left", (e, cx) => {
      press(e);
      cx.stop_propagation();
    }).on_mouse_down("right", (_e, cx) => cx.stop_propagation());
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
  // copy, so the list copy skips the command loop or a swap runs twice.
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
        else if (command.startsWith("select-agent-")) this.selectAgent(Number(command.slice("select-agent-".length)));
        else if (command.startsWith("select-")) this.selectNumber(Number(command.slice("select-".length)));
      }
    });
  }

  initList(cx) {
    this.listing = true;
    this.chosen = 0;
    this.handle = cx.focus_handle();
    this.handle.focus();
  }

  renderList() {
    const rows = agentList(agents());
    return agentRows(theme(), rows, Math.min(this.chosen, rows.length - 1), (a) => this.goTo(a))
      .id("tm-agent-list")
      .track_focus(this.handle)
      .on_key_down((e, cx) => this.listKeyDown(e, rows, cx));
  }

  listKeyDown(e, rows, cx) {
    const key = listKey(e.keystroke, this.chosen, rows.length);
    if (!key) return;
    if ("go" in key) {
      if (rows[key.go]) this.goTo(rows[key.go]);
      return;
    }
    this.chosen = key.chosen;
    cx.notify();
  }

  goTo(a) {
    closeOverlay(props().overlay);
    run("agent.focus", { terminal: a.address });
  }

  tick(cx) {
    cx.timer.after(untilNextMinute(new Date()), (cx) => {
      cx.notify();
      this.tick(cx);
    });
  }

  selectLastTab() {
    const id = lastTab(this.observe(), spaces());
    if (id) run("tab.select", { id });
    else notify({ title: "No previous tab", level: "info" });
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
    const height = 8 + Math.min(Math.max(agents().length, 1), 12) * ROW;
    const at = this.agentsAt;
    openOverlay({
      mod: "tab-bar",
      kind: "popup",
      width: LIST_WIDTH,
      height,
      props: { popup: "agents" },
      at: at ? { x: at.x + at.width - LIST_WIDTH, y: at.y - height - 6 } : "pointer",
    });
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
    return after;
  }

  render() {
    if (this.listing) return this.renderList();
    this.observe();
    const numbers = this.number();
    this.place(numbers);
    const t = theme();
    const C = colors(t);
    const space = spaces().find((p) => p.active);
    if (!space) return div();
    const all = panes();
    const w = win() ?? {};
    const records = terminals();
    const list = agents();

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
        .child(programIcon(t, C, p))
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
              .on_click(() => openOverlay({ mod: "picker", kind: "popup", at: "top", offset: 40, width: 640, height: 0.8 }))
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
            own(h_flex(), (e) => (this.agentsAt = e.bounds))
              .id("tm-agents")
              .gap(6)
              .items_center()
              .cursor_pointer()
              .hover((s) => s.text_color(C.text))
              .on_click(() => this.openAgents())
              .child(div().size(6).rounded(3).bg(C.dim))
              .child(agentsText(list))
              .child(h_flex().gap(3).children(list.filter((a) => a.status !== "idle").map((a) => div().size(6).rounded(3).bg(t[a.status]))))
              .when(Boolean(needsText(list)), (el) => el.child(div().text_color(t.blocked).child(needsText(list)))),
          )
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
