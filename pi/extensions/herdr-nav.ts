// In a Herdr terminal, ctrl-h/j/k/l move the Herdr pane left, down, up and
// right inside pi, as they do in zsh and nvim. The extension acts only when
// HC_TERMINAL_ID is set, and only for the interactive pi (mode "tui"), so a
// subagent does nothing. It uses a terminal input listener and not
// registerShortcut. pi reserves ctrl+k for delete to end of line, and skips an
// extension shortcut on it. A rebind at load is lost on /reload. The listener
// skips key releases, because pi asks the terminal for them. herdr-app is not
// on PATH. The pane move runs in the background, and its output stays hidden.
// Outside Herdr, pi keeps its keys.
// keys.json sends ctrl-alt-k for ctrl-a ctrl-k and ctrl-alt-j for ctrl-a
// ctrl-j. pi/keybindings.json gives those keys to delete to end of line and
// to a new line.

import { execFile } from "node:child_process";
import { homedir } from "node:os";
import { join } from "node:path";
import { isKeyRelease, matchesKey } from "@earendil-works/pi-tui";

const DIRECTIONS = { "ctrl+h": "left", "ctrl+j": "down", "ctrl+k": "up", "ctrl+l": "right" };

export default function (pi) {
  if (!process.env.HC_TERMINAL_ID) return;
  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    ctx.ui.onTerminalInput((data) => {
      if (isKeyRelease(data)) return;
      const key = Object.keys(DIRECTIONS).find((name) => matchesKey(data, name));
      if (!key) return;
      go(DIRECTIONS[key]);
      return { consume: true };
    });
  });
}

function go(direction) {
  execFile(join(homedir(), ".local/bin/herdr-app"), ["do", "pane.go", JSON.stringify({ direction })], () => {});
}
