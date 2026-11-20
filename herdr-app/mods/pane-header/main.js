// Pane header with a centered name. Its props are { pane, terminal }.

import { View, div, svg, image } from "gpui-kit";
import { h_flex } from "gpui-base";
import { panes, props, run, home, theme } from "herdr";

// Four 15 px icons with 4 px padding, and 8 px between them.
const BUTTONS_WIDTH = 4 * (15 + 2 * 4) + 3 * 8;

function folder(cwd) {
  if (!cwd) return "";
  const h = home();
  return cwd === h ? "~" : cwd.startsWith(h + "/") ? "~" + cwd.slice(h.length) : cwd;
}

export default class PaneHeader extends View {
  me() {
    return panes().find((p) => p.pane === props()?.pane);
  }

  button(t, id, icon, command, args) {
    return div()
      .id(id)
      .p(4)
      .rounded(5)
      .text_color(t.dim)
      .cursor_pointer()
      // In Solarized the theme hover color equals the pane background, so it would not show.
      .hover((s) => s.bg(t.surface).text_color(t.foreground))
      .on_click((_e, cx) => {
        cx.stop_propagation();
        run(command, args);
      })
      .child(svg(`mods/pane/${icon}.svg`).size(15));
  }

  render() {
    const p = this.me();
    if (!p) return div();
    const t = theme();
    const pane = p.pane;
    const g = p.program;
    const where = folder(p.cwd);
    // Shells often put the folder in their title already.
    const title = p.title || "shell";
    const dir = where && !title.includes(where) && !/^[~/]/.test(title) ? where : "";
    // The name sits in the middle, clear of the macOS window buttons over the
    // top-left pane. The two sides share the rest equally, so it stays centered.
    // The left side is never narrower than the buttons, so a narrow pane keeps
    // the name clear too.
    return h_flex()
      .id(`tm-head-${pane}`)
      .size_full()
      .px(8)
      .gap(8)
      .items_center()
      .text_size(14)
      .on_click(() => run("pane.focus", { pane }))
      .child(div().flex_1().min_w(BUTTONS_WIDTH))
      .child(
        h_flex()
          .min_w(0)
          .gap(8)
          .items_center()
          .when(Boolean(g?.icon), (el) =>
            el.child(g.tint ? svg(g.icon).size(16).flex_none().text_color(t.foreground) : image(g.icon).w(15).h(15).flex_none()),
          )
          .child(div().flex_none().max_w(320).truncate().font_semibold().text_color(p.focused ? t.foreground : t.muted).child(title))
          .when(Boolean(dir), (el) => el.child(div().min_w(0).truncate().text_color(t.dim).child(dir))),
      )
      .child(
        h_flex()
          .flex_1()
          .gap(8)
          .justify_end()
          .child(this.button(t, `th-r-${pane}`, "split-right", "pane.split", { direction: "right", pane }))
          .child(this.button(t, `th-d-${pane}`, "split-down", "pane.split", { direction: "down", pane }))
          .child(this.button(t, `th-z-${pane}`, p.zoomed ? "unzoom" : "zoom", "pane.zoom", { pane }))
          .child(this.button(t, `th-x-${pane}`, "close", "pane.close", { pane })),
      );
  }
}
