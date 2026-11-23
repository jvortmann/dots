import { div, svg } from "gpui-kit";

// The mark at the end of an agent row of the stock sidebar.
export function statusMark(t, status) {
  if (status === "working") return svg("mods/workspace-chrome/spinner.svg").size(12).mx(1).flex_none().text_color(t.working).spin(900);
  if (status === "blocked") return div().flex_none().px(6).h(18).rounded(4).bg(t.blocked + "26").text_size(10.5).font_semibold().text_color(t.blocked).flex().items_center().child("Needs you");
  if (status === "done") return dot(t.done);
  if (status === "idle") return div().size(7).mx(3).flex_none().rounded(4).border(1.5).border_color(t.idle);
  return div().size(7).mx(3).flex_none();
}

// The mark of an agent in the bar. The bar names a blocked agent in "N needs
// you", so it shows a dot and not the pill.
export function barMark(t, status) {
  if (status === "blocked") return dot(t.blocked);
  return statusMark(t, status);
}

function dot(color) {
  return div().size(7).mx(3).flex_none().rounded(4).bg(color);
}
