import { div } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { statusWord } from "./status.js";

export const ROW = 28;

export function agentRows(t, rows, chosen, go) {
  return v_flex()
    .size_full()
    .overflow_y_scrollbar()
    .p(4)
    .bg(t.popover)
    .text_size(13)
    .children(rows.map((a, i) => row(t, a, i === chosen, go)))
    .when(rows.length === 0, (el) => el.child(h_flex().h(ROW).px(8).items_center().text_color(t.muted).child("No agents")));
}

function row(t, a, chosen, go) {
  return h_flex()
    .id(`tm-list-${a.address}`)
    .h(ROW)
    .px(8)
    .gap(8)
    .items_center()
    .rounded(4)
    .text_color(t.foreground)
    .cursor_pointer()
    .when(chosen, (el) => el.bg(t.selected))
    .hover((s) => s.bg(t.selected))
    .on_click(() => go(a))
    .child(div().flex_none().w(10).text_color(t.muted).child(a.number ? `${a.number}` : ""))
    .child(div().flex_none().size(6).rounded(3).bg(t[a.status]))
    .child(div().flex_none().max_w(140).truncate().child(a.program.name))
    .child(div().flex_1().min_w(0).truncate().text_color(t.muted).child(`${a.space_name} · ${a.tab_name}`))
    .child(div().flex_none().text_color(a.status === "blocked" ? t.blocked : t.muted).child(statusWord(a.status)));
}
