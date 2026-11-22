// The look is the one of the recent picker: the canvas, the chosen row like the
// shown tab, and plain rows.

import { div } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { statusWord } from "./status.js";
import { quarter } from "./edge.js";

export const ROW = 28;

export function agentRows(t, rows, chosen, go) {
  return v_flex()
    .size_full()
    .overflow_y_scrollbar()
    .p(4)
    .bg(t.canvas)
    .text_size(13)
    .children(rows.map((a, i) => row(t, a, i === chosen, go)))
    .when(rows.length === 0, (el) => el.child(h_flex().h(ROW).px(8).items_center().text_color(t.muted).child("No agents")));
}

function row(t, a, chosen, go) {
  const edge = quarter(t.border);
  return h_flex()
    .id(`tm-list-${a.key}`)
    .h(ROW)
    .px(8)
    .gap(8)
    .items_center()
    .rounded(4)
    .text_color(t.muted)
    .cursor_pointer()
    .when(chosen, (el) => el.px(7).bg(t.surface).border_1().border_color(edge).text_color(t.foreground))
    .hover((s) => s.text_color(t.foreground))
    .on_click(() => go(a))
    .children(a.depth ? childCells(t, a) : agentCells(t, a));
}

function agentCells(t, a) {
  return [
    div().flex_none().w(10).text_color(t.dim).child(a.number ? `${a.number}` : ""),
    div().flex_none().size(6).rounded(3).bg(t[a.status]),
    div().flex_none().max_w(140).truncate().child(a.program.name),
    div().flex_1().min_w(0).truncate().text_color(t.dim).child(`${a.space_name} · ${a.tab_name}`),
    div().flex_none().text_color(a.status === "blocked" ? t.blocked : t.dim).child(statusWord(a.status)),
  ];
}

function childCells(t, c) {
  return [
    div().flex_none().w(10 + 14 * c.depth),
    div().flex_none().size(6).rounded(3).bg(t[c.status]),
    div().flex_none().max_w(140).truncate().child(c.title),
    div().flex_1().min_w(0).truncate().text_color(t.dim).child(c.msg),
  ];
}
