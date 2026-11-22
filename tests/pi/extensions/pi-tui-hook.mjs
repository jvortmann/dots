// pi gives an extension its own pi-tui, so this hook points node at it.
import { registerHooks } from "node:module";
import { pathToFileURL } from "node:url";

const piTui = pathToFileURL(process.env.PI_TUI).href;
registerHooks({
  resolve: (specifier, context, next) => next(specifier === "@earendil-works/pi-tui" ? piTui : specifier, context),
});
