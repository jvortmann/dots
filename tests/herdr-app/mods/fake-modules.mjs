import { registerHooks } from "node:module";

// Resolves each named module, such as herdr, to the code given for it.
export function fakeModules(sources) {
  registerHooks({
    resolve: (specifier, context, next) =>
      Object.hasOwn(sources, specifier)
        ? { url: `data:text/javascript,${encodeURIComponent(sources[specifier])}`, shortCircuit: true }
        : next(specifier, context),
  });
}

// The nextCommand of a fake herdr. It gives the commands of globalThis.app in
// turn. With none left, it calls app.waiting and never gives one.
export const NEXT_COMMAND = `
  export const nextCommand = () => {
    const app = globalThis.app;
    if (app.commands.length) return Promise.resolve(app.commands.shift());
    app.waiting();
    return new Promise(() => {});
  };
`;
