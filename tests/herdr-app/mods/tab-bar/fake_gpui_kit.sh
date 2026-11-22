#!/bin/bash

# Prints what $2, a call to the exports of the module $1, draws, in the
# Solarized dark theme. A fake gpui-kit records each element as the calls
# that built it.
drawn_by() {
  MODULE="$1" CALL="$2" mise x node@latest -- node --input-type=module -e '
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
    const module = await import(process.env.MODULE);
    const t = {
      canvas: "#002b36", foreground: "#839496", dim: "#586e75", ansi13: "#6c71c4",
      working: "#b58900", blocked: "#dc322f", done: "#859900", idle: "#586e75",
    };
    console.log(String(new Function("t", ...Object.keys(module), `return ${process.env.CALL}`)(t, ...Object.values(module))));
  ' 2>&1
}
