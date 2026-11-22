import { div, svg, image } from "gpui-kit";
import { glyphColor } from "./glyph.js";

// The program's icon from the app's table: its glyph in its color, or its picture.
export function programGlyph(t, g) {
  return g.tint ? svg(g.icon).size(14).text_color(glyphColor(g, t.canvas, t.foreground, t)) : image(g.icon).w(14).h(14);
}

// The icon in a 14 px box, with a dot in the corner for a status that is not idle.
export function programIcon(t, p, status) {
  const g = p?.program;
  const dot = status && status !== "idle" ? t[status] : null;
  return div()
    .relative()
    .flex_none()
    .w(14)
    .h(14)
    .flex()
    .items_center()
    .justify_center()
    .when(Boolean(g?.icon), (el) => el.child(programGlyph(t, g)))
    .when(Boolean(dot), (el) => el.child(div().absolute().top(-2).right(-2).w(7).h(7).rounded_full().bg(dot)));
}
