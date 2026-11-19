// The bar at the bottom of the layout: space picker, tabs, host and time, and
// window controls. It runs last-tab (ctrl-a ctrl-a), which selects the tab
// shown before.

import { View, div, svg, image } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, panes, run, theme, home, openOverlay, window as win, shared, setShared, nextCommand, notify, exec, checking } from "herdr";
import { tabLabel } from "./label.js";
import { statusText, untilNextMinute } from "./status.js";
import { observeTabs, lastTab } from "./history.js";

// Shared state, not a field: another layout, a save or a restart starts the mod fresh.
const HISTORY = "tab-bar.tab-history";

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
    status: t.accent,
  };
}

function folder(cwd) {
  if (!cwd) return "";
  const h = home();
  return cwd === h ? "~" : cwd.startsWith(h + "/") ? "~" + cwd.slice(h.length) : cwd;
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
    .w(26)
    .h(26)
    .rounded(7)
    .border_1()
    .border_color(C.tabEdge)
    .bg(g?.tile ?? C.chip)
    .flex()
    .items_center()
    .justify_center()
    .when(Boolean(g?.icon), (el) =>
      el.child(g.tint ? svg(g.icon).size(15).text_color(g.color ?? C.text) : image(g.icon).w(15).h(15)),
    )
    .when(Boolean(dot), (el) =>
      el.child(div().absolute().top(-4).right(-4).w(11).h(11).rounded_full().border_2().border_color(C.tray).bg(dot)),
    );
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

function iconButton(C, id, icon, onClick) {
  return own(div())
    .id(id)
    .flex_none()
    .p(7)
    .rounded(8)
    .text_color(C.dim)
    .cursor_pointer()
    .hover((s) => s.bg(C.chip).text_color(C.text))
    .on_click(onClick)
    .child(svg(`mods/tab-bar/${icon}.svg`).size(17));
}

export default class TerminalsBar extends View {
  init(_props, cx) {
    this.host = "";
    if (!checking()) cx.spawn(async (cx) => {
      try {
        this.host = (await exec("hostname", ["-s"])).stdout.trim();
        cx.notify();
      } catch {
        // Without the host, the bar shows the time only.
      }
    });
    this.tick(cx);
    cx.spawn(async () => {
      for (;;) {
        const command = await nextCommand();
        if (command === "last-tab") this.selectLastTab();
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

  observe() {
    const before = shared(HISTORY) ?? {};
    const after = observeTabs(before, spaces());
    if (JSON.stringify(after) !== JSON.stringify(before)) setShared(HISTORY, after);
    return after;
  }

  render() {
    this.observe();
    const t = theme();
    const C = colors(t);
    const space = spaces().find((p) => p.active);
    if (!space) return div();
    const all = panes();
    const w = win() ?? {};

    const tab = (c) => {
      const p = lead(all, c.id);
      const where = folder(p?.cwd);
      return own(h_flex())
        .id(`tm-${c.id}`)
        .flex_shrink(1)
        .w(260)
        .min_w(0)
        .h_full()
        .pl(5)
        .pr(12)
        .gap(9)
        .items_center()
        .rounded(13)
        .border_1()
        .cursor_pointer()
        .text_size(13)
        .when(c.active, (el) => el.bg(C.tab).border_color(C.tabEdge))
        .when(!c.active, (el) => el.border_color(C.tray).hover((s) => s.bg(C.hover)))
        .on_click(() => run("tab.select", { id: c.id }))
        .on_mouse_down("right", () =>
          openOverlay({ mod: "menu", kind: "popup", width: 200, props: { tab: "tab", target: { id: c.id, space: space.id } } }),
        )
        .child(tile(t, C, p))
        .child(
          h_flex()
            .min_w(0)
            .gap(6)
            .truncate()
            .child(div().flex_none().text_color(c.active ? C.text : C.label).child(tabLabel(c)))
            .when(Boolean(where), (el) => el.child(div().truncate().text_color(C.dim).child(where))),
        );
    };

    return h_flex()
      .size_full()
      .gap(8)
      .items_center()
      .child(
        own(h_flex())
          .id("tm-space")
          .flex_none()
          .h(30)
          .pl(10)
          .pr(12)
          .gap(8)
          .items_center()
          .rounded_full()
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
          .rounded(16)
          .bg(C.tray)
          .children(space.tabs.map(tab)),
      )
      .child(div().flex_1())
      .child(iconButton(C, "tm-keys", "command", () => run("app.palette")))
      .child(iconButton(C, "tm-new", "plus", () => run("tab.new", { space: space.id })))
      .child(div().flex_none().pl(4).pr(8).text_size(13).text_color(C.status).child(statusText(this.host, new Date())))
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
