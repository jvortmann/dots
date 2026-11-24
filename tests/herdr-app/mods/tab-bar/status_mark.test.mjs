import assert from "node:assert/strict";
import { test } from "node:test";
import { importWithFakeKit, t } from "./fake-gpui-kit.mjs";

const { barMark, statusMark } = await importWithFakeKit("../../../../herdr-app/mods/tab-bar/status-mark.js");

const SPINNER = 'svg("mods/workspace-chrome/spinner.svg").size(12).mx(1).flex_none().text_color("#b58900").spin(900)';

test("a working agent shows the spinner of the sidebar in the working color", () => {
  assert.equal(String(statusMark(t, "working")), SPINNER);
});

// The sidebar rounds the pill 5 px. The list keeps the 4 px corners of its rows.
test("a blocked agent shows the needs you pill of the sidebar with square corners", () => {
  assert.equal(
    String(statusMark(t, "blocked")),
    'div().flex_none().px(6).h(18).rounded(4).bg("#dc322f26").text_size(10.5).font_semibold().text_color("#dc322f").flex().items_center().child("Needs you")',
  );
});

test("the fill of the pill keeps the share of a blocked color with an alpha of its own", () => {
  const drawn = String(statusMark({ ...t, blocked: "#e06c75cc" }, "blocked"));
  assert.ok(drawn.includes('.bg("#e06c751f")'), drawn);
});

test("a done agent shows the dot of the sidebar in the done color", () => {
  assert.equal(String(statusMark(t, "done")), 'div().size(7).mx(3).flex_none().rounded(4).bg("#859900")');
});

test("an idle agent shows the ring of the sidebar in the idle color", () => {
  assert.equal(String(statusMark(t, "idle")), 'div().size(7).mx(3).flex_none().rounded(4).border(1.5).border_color("#586e75")');
});

// The bar says "N needs you" after the marks, so a pill would say it twice.
test("in the bar a blocked agent shows a dot in the blocked color and no pill", () => {
  assert.equal(String(barMark(t, "blocked")), 'div().size(7).mx(3).flex_none().rounded(4).bg("#dc322f")');
});

test("in the bar a working or done agent shows the mark of the sidebar", () => {
  assert.equal(`${barMark(t, "working")} ${barMark(t, "done")}`, `${SPINNER} div().size(7).mx(3).flex_none().rounded(4).bg("#859900")`);
});

// A child record can have no state. The sidebar draws a clear dot for it.
test("a status with no mark keeps the place of the mark empty", () => {
  assert.equal(String(statusMark(t, undefined)), "div().size(7).mx(3).flex_none()");
});
