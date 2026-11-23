// The look is the one of the recent picker: the canvas, the chosen row like the
// shown tab, and plain rows. A row reads like a row of the stock sidebar: the
// program icon, the space and tab, the time since the last change of state,
// and the status mark.

import { div, svg } from "gpui-kit";
import { h_flex, v_flex, Input } from "gpui-base";
import { statusMark } from "./status-mark.js";
import { alpha } from "./alpha.js";
import { programGlyph } from "./program-icon.js";
import { FILTERS } from "./search.js";

export const ROW = 28;
const HEAD_PAD = 4;
const FIELD = 32;
const HEAD_GAP = 6;
const TAB = 24;
// The height of agentHead: its top padding, the field, the gap and the tabs.
export const HEAD = HEAD_PAD + FIELD + HEAD_GAP + TAB;
const LABELS = { all: "All", blocked: "Needs you", working: "Working", done: "Done" };
const KEYS = { all: "(⌥l)", blocked: "(⌥n)", working: "(⌥w)", done: "(⌥d)" };

export function agentHead(t, input, filter, counts, pick) {
  return v_flex()
    .flex_none()
    .p(HEAD_PAD)
    .pb(0)
    .gap(HEAD_GAP)
    .child(h_flex().h(FIELD).px(10).gap(8).items_center().rounded(4).border_1().border_color(t.accent).bg(t.background)
      .child(svg("mods/workspace-chrome/search.svg").size(15).text_color(t.dim))
      .child(Input.new(input).flex_1().h_full().text_size(13).text_color(t.foreground)))
    .child(h_flex().gap(2).children(FILTERS.map((f) => filterTab(t, f, counts[f], f === filter, pick))));
}

export function agentRows(t, rows, chosen, go, empty) {
  return v_flex()
    .w_full()
    .flex_none()
    .overflow_y_scrollbar()
    .p(4)
    .bg(t.canvas)
    .text_size(13)
    .children(rows.map((a, i) => row(t, a, i === chosen, go)))
    .when(rows.length === 0, (el) => el.child(h_flex().h(ROW).px(8).items_center().text_color(t.muted).child(empty)));
}

function filterTab(t, f, count, chosen, pick) {
  return h_flex()
    .id(`tm-filter-${f}`)
    .flex_none()
    .h(TAB)
    .px(6)
    .gap(4)
    .items_center()
    .text_size(11)
    .rounded(4)
    .text_color(t.muted)
    .cursor_pointer()
    .when(chosen, (el) => el.px(5).bg(t.surface).border_1().border_color(alpha(t.border, 1 / 4)).text_color(t.foreground))
    .hover((s) => s.text_color(t.foreground))
    .on_click((_e, cx) => pick(f, cx))
    .child(LABELS[f])
    .child(div().when(chosen, (el) => el.text_color(f === "all" ? t.foreground : t[f])).child(String(count)))
    .child(div().text_color(t.dim).child(KEYS[f]));
}

function row(t, a, chosen, go) {
  const edge = alpha(t.border, 1 / 4);
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
    agentIcon(t, a),
    div().flex_1().min_w(0).truncate().child(`${a.space_name} · ${a.tab_name}`),
    a.time && div().flex_none().text_size(11).text_color(t.dim).child(a.time),
    statusMark(t, a.status),
  ].filter(Boolean);
}

function agentIcon(t, a) {
  const g = a.program;
  if (!g.icon) return div().flex_none().max_w(140).truncate().child(g.name);
  return div()
    .id(`tm-icon-${a.key}`)
    .tooltip(g.name)
    .accessibility_label(g.name)
    .flex_none()
    .size(14)
    .flex()
    .items_center()
    .justify_center()
    .child(programGlyph(t, g));
}

function childCells(t, c) {
  return [
    div().flex_none().w(10 + 22 * c.depth),
    div().flex_none().max_w(140).truncate().child(c.title),
    div().flex_1().min_w(0).truncate().text_color(t.dim).child(c.msg),
    statusMark(t, c.status),
  ];
}
