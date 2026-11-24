// Resolves gpui-kit to a fake that records each element as the calls that
// built it, so String() of an element gives those calls. Import a module that
// draws with importWithFakeKit, after this module loads.
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

// The Solarized dark theme.
export const t = {
  canvas: "#002b36", foreground: "#839496", dim: "#586e75", ansi13: "#6c71c4",
  working: "#b58900", blocked: "#dc322f", done: "#859900", idle: "#586e75",
};

export function importWithFakeKit(path) {
  return import(new URL(path, import.meta.url));
}
