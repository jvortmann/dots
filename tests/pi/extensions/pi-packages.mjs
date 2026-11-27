// pi gives an extension its own packages, so a test takes them from the pi
// that mise installed. mise needs the real HOME to find that pi.
import { spawnSync } from "node:child_process";
import { existsSync } from "node:fs";
import { registerHooks } from "node:module";
import { homedir } from "node:os";
import { pathToFileURL } from "node:url";

const where = spawnSync("mise", ["where", "npm:@earendil-works/pi-coding-agent"], { encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] });

export const PI_DIR = `${where.stdout?.trim() ?? ""}/lib/node_modules/@earendil-works/pi-coding-agent`;

// Where pi installs the subagents package. The package is not in this repo.
export const SUBAGENTS_DIR = `${homedir()}/.config/pi/npm/node_modules/@tintinweb/pi-subagents`;

const PI_TUI = `${PI_DIR}/node_modules/@earendil-works/pi-tui/dist/index.js`;
const PI_CODING_AGENT = `${PI_DIR}/dist/index.js`;

// Each resolve function points the imports of one package at the copy in pi.
// It gives false when pi is missing.
export function resolvePiTui() {
  return redirect("@earendil-works/pi-tui", PI_TUI);
}

export function resolvePiCodingAgent() {
  return redirect("@earendil-works/pi-coding-agent", PI_CODING_AGENT);
}

function redirect(specifier, file) {
  if (!existsSync(file)) return false;
  const url = pathToFileURL(file).href;
  registerHooks({
    resolve: (wanted, context, next) => next(wanted === specifier ? url : wanted, context),
  });
  return true;
}
