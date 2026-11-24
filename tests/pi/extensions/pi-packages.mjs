// pi gives an extension its own packages, so a test takes them from the pi
// that mise installed. mise needs the real HOME to find that pi.
import { spawnSync } from "node:child_process";
import { existsSync } from "node:fs";
import { registerHooks } from "node:module";
import { pathToFileURL } from "node:url";

const where = spawnSync("mise", ["where", "npm:@earendil-works/pi-coding-agent"], { encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] });

export const PI_DIR = `${where.stdout?.trim() ?? ""}/lib/node_modules/@earendil-works/pi-coding-agent`;

const PI_TUI = `${PI_DIR}/node_modules/@earendil-works/pi-tui/dist/index.js`;

// Points the imports of @earendil-works/pi-tui at the pi-tui of pi. Gives
// false when pi is missing.
export function resolvePiTui() {
  if (!existsSync(PI_TUI)) return false;
  const piTui = pathToFileURL(PI_TUI).href;
  registerHooks({
    resolve: (specifier, context, next) => next(specifier === "@earendil-works/pi-tui" ? piTui : specifier, context),
  });
  return true;
}
