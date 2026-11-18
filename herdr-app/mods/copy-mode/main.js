// Copy mode: ctrl-a [ shows the text of the focused terminal in a read-only
// nvim, in a popup. The design comes from the tmux-compat mod of herdr-term
// (https://github.com/cristianoliveira/herdr-term).

import { View, div } from "gpui-kit";
import { focused, hc, appHome, home, openOverlay, nextCommand, notify, props, run } from "herdr";

export default class CopyMode extends View {
  init(_props, cx) {
    // The copy in the popup has the terminal prop, and only kills that terminal
    // on close. The copy in the layout takes the command, because closing an
    // overlay cancels the calls of its copies.
    this.terminal = props()?.terminal;
    if (this.terminal) return;
    cx.spawn(async () => {
      for (;;) {
        if ((await nextCommand()) !== "open") continue;
        try {
          await this.open();
        } catch (error) {
          notify({ title: "Copy mode failed", body: String(error?.message ?? error), level: "error" });
        }
      }
    });
  }

  async open() {
    const source = focused()?.terminal;
    if (!source) {
      notify({ title: "Copy mode", body: "Focus a terminal first.", level: "info" });
      return;
    }
    const view = `${appHome()}/mods/copy-mode/view.sh`;
    const result = await hc([
      "run", "--bg", "--json", "--no-parent", "--no-notify", "--rm", "--cwd", home(),
      "--", "/bin/sh", view, source,
    ]);
    const address = result.code === 0 ? JSON.parse(result.stdout).address : null;
    if (!address) {
      notify({ title: "Copy mode failed", body: result.stderr || result.stdout, level: "error" });
      return;
    }
    openOverlay({
      kind: "dialog",
      width: 0.85,
      height: 0.75,
      layout: {
        type: "column",
        children: [
          { type: "block", size: { px: 1 }, content: { mod: "copy-mode", props: { terminal: address } } },
          { type: "block", content: { terminal: address } },
        ],
      },
    });
  }

  async close() {
    if (this.terminal) run("terminal.kill", { terminal: this.terminal });
  }

  render() {
    return div();
  }
}
