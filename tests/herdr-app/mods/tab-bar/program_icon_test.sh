#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
ICON="$ROOT/herdr-app/mods/tab-bar/program-icon.js"

function set_up() {
  [[ -f $ICON ]] || bashunit::fail "missing the file under test: $ICON"
}

function test_a_glyph_draws_14_px_in_its_glyph_color() {
  assert_same 'svg("icons/pi.svg").size(14).text_color("#6c71c4")' \
    "$(icon_of 'programGlyph(t, { key: "pi", tint: true, icon: "icons/pi.svg" })')"
}

function test_a_glyph_with_no_color_of_its_own_takes_the_text_color() {
  assert_same 'svg("x.svg").size(14).text_color("#839496")' "$(icon_of 'programGlyph(t, { key: "x", tint: true, icon: "x.svg" })')"
}

# A picture, such as the violet pi of programs.json, keeps its own colors.
function test_a_picture_draws_14_px_as_it_is() {
  assert_same 'image("icons/pi.svg").w(14).h(14)' \
    "$(icon_of 'programGlyph(t, { key: "pi", tint: false, icon: "icons/pi.svg" })')"
}

function test_a_status_that_is_not_idle_puts_its_dot_on_the_corner_of_the_icon() {
  assert_same 'div().relative().flex_none().w(14).h(14).flex().items_center().justify_center().child(image("x.svg").w(14).h(14)).child(div().absolute().top(-2).right(-2).w(7).h(7).rounded_full().bg("#b58900"))' \
    "$(icon_of 'programIcon(t, { program: { tint: false, icon: "x.svg" } }, "working")')"
}

function test_an_idle_program_has_no_dot() {
  assert_same 'div().relative().flex_none().w(14).h(14).flex().items_center().justify_center().child(image("x.svg").w(14).h(14))' \
    "$(icon_of 'programIcon(t, { program: { tint: false, icon: "x.svg" } }, "idle")')"
}

function test_a_program_with_no_icon_draws_an_empty_box() {
  assert_same 'div().relative().flex_none().w(14).h(14).flex().items_center().justify_center()' \
    "$(icon_of 'programIcon(t, { program: { icon: null } }, "idle")')"
}

# Prints what $1, a call to the exports of program-icon.js, draws, in the
# Solarized dark theme. A fake gpui-kit records each element as the calls
# that built it.
icon_of() {
  CALL="$1" ICON="$ICON" mise x node@latest -- node --input-type=module -e '
    import { registerHooks } from "node:module";
    const fake = `
      const element = (name, args) => {
        const calls = [name + "(" + args.map((a) => JSON.stringify(a)).join(", ") + ")"];
        const self = new Proxy({}, {
          get: (_, method) => {
            if (typeof method === "symbol") return undefined;
            if (method === "toString") return () => calls.join(".");
            if (method === "when") return (yes, build) => (yes ? build(self) : self);
            return (...a) => {
              calls.push(method + "(" + a.map((x) => (typeof x === "object" ? String(x) : JSON.stringify(x))).join(", ") + ")");
              return self;
            };
          },
        });
        return self;
      };
      export const div = (...a) => element("div", a);
      export const svg = (...a) => element("svg", a);
      export const image = (...a) => element("image", a);
    `;
    registerHooks({
      resolve: (specifier, context, next) =>
        specifier === "gpui-kit" ? { url: `data:text/javascript,${encodeURIComponent(fake)}`, shortCircuit: true } : next(specifier, context),
    });
    const icon = await import(process.env.ICON);
    const t = { canvas: "#002b36", foreground: "#839496", ansi13: "#6c71c4", working: "#b58900", idle: "#586e75" };
    console.log(String(new Function("t", ...Object.keys(icon), `return ${process.env.CALL}`)(t, ...Object.values(icon))));
  ' 2>&1
}
