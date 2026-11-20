// The bar at the bottom of the layout: space picker, tabs, status, and window
// controls. The status is the agent count, the agents that need you, the
// machine label and the time. It runs last-tab (ctrl-a ctrl-a), which selects
// the tab shown before. Each tab keeps its number, as in tmux: the bar numbers
// each new tab and moves it into number order, and select-N selects by number.

import { View, div, svg, image } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, panes, agents, terminals, run, theme, openOverlay, window as win, shared, setShared, nextCommand, notify, exec, checking } from "herdr";
import { tabText } from "./label.js";
import { agentsText, needsText, machineLabel, timeText, untilNextMinute } from "./status.js";
import { observeTabs, lastTab } from "./history.js";
import { numberTabs, nextMove, swapNumbers, tabNumbered } from "./numbers.js";

// Shared state, not a field: another layout, a save or a restart starts the mod fresh.
const HISTORY = "tab-bar.tab-history";
const NUMBERS = "tab-bar.tab-numbers";

function colors(t) {
  return {
    tray: t.chrome,
    // The shown tab has an edge and bright text; a hovered tab gets only a fill.
    tab: t.selected,
    tabEdge: t.border,
    hover: t.hover,
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

// The program's tile from the app's table: its color, its glyph (or logo) on it.
function tile(t, C, p) {
  const g = p?.program;
  const dot = p?.status && p.status !== "idle" ? t[p.status] : null;
  return div()
    .relative()
    .flex_none()
    .w(18)
    .h(18)
    .rounded(2)
    .border_1()
    .border_color(C.tabEdge)
    .bg(g?.tile ?? C.chip)
    .flex()
    .items_center()
    .justify_center()
    .when(Boolean(g?.icon), (el) =>
      el.child(g.tint ? svg(g.icon).size(12).text_color(g.color ?? C.text) : image(g.icon).w(12).h(12)),
    )
    .when(Boolean(dot), (el) =>
      el.child(div().absolute().top(-3).right(-3).w(9).h(9).rounded_full().border_1().border_color(C.tray).bg(dot)),
    );
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
function own(el) {
  return el.on_mouse_down("left", (_e, cx) => cx.stop_propagation()).on_mouse_down("right", (_e, cx) => cx.stop_propagation());
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
  init(_props, cx) {
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
        else if (command.startsWith("select-")) this.selectNumber(Number(command.slice("select-".length)));
      }
    });
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
        .pl(4)
        .pr(8)
        .gap(6)
        .items_center()
        .rounded(2)
        .border_1()
        .cursor_pointer()
        .text_size(13)
        .when(c.active, (el) => el.bg(C.tab).border_color(C.tabEdge))
        .when(!c.active, (el) => el.border_color(C.tray).hover((s) => s.bg(C.hover)))
        .on_click(() => run("tab.select", { id: c.id }))
        .on_mouse_down("right", () =>
          openOverlay({ mod: "menu", kind: "popup", width: 200, props: { tab: "tab", target: { id: c.id, space: space.id } } }),
        )
        .child(div().flex_none().text_color(C.label).child(`${numbers[space.id][c.id]}`))
        .child(tile(t, C, p))
        .child(
          h_flex()
            .min_w(0)
            .truncate()
            .when(Boolean(text), (el) => el.child(div().truncate().text_color(c.active ? C.text : C.label).child(text))),
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
          .items_center()
          .child(
            own(h_flex())
              .id("tm-space")
              .flex_none()
              .h(36)
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
              .h(36)
              .p(3)
              .gap(3)
              .rounded(2)
              .bg(C.tray)
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
            h_flex()
              .gap(6)
              .items_center()
              .child(div().size(6).rounded(3).bg(C.dim))
              .child(agentsText(list))
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
