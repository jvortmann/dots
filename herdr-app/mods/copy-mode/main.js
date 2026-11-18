// Copy mode: ctrl-a [ shows the text of the focused terminal, with its colors,
// in a read-only nvim in the same pane. The design comes from the tmux-compat
// mod of herdr-term (https://github.com/cristianoliveira/herdr-term).

import { View, div } from "gpui-kit";
import { appHome, exec, focused, hc, home, nextCommand, notify, run, terminals } from "herdr";
import { openCopyMode } from "./open.js";

const app = {
  hc,
  run,
  terminals,
  get home() {
    return home();
  },
  sleep: (seconds) => exec("sleep", [String(seconds)]),
};

export default class CopyMode extends View {
  init(_props, cx) {
    this.keyboard = cx.focus_handle();
    this.early = null;
    cx.spawn(async () => {
      for (;;) {
        if ((await nextCommand()) !== "open") continue;
        try {
          await this.open();
        } catch (error) {
          notify({ title: "Copy mode failed", body: String(error?.message ?? error), level: "error" });
        }
        this.early = null;
      }
    });
  }

  async open() {
    const { terminal: source, pane, shown } = focused() ?? {};
    // Copy mode already shows in this pane.
    if (shown) return;
    if (!source || !pane) {
      notify({ title: "Copy mode", body: "Focus a terminal first.", level: "info" });
      return;
    }
    // Keys typed while nvim starts come to this copy, and not to the shell.
    this.early = [];
    this.keyboard.focus();
    await openCopyMode(app, { source, pane, view: `${appHome()}/mods/copy-mode/view.sh`, early: this.early });
  }

  render() {
    return div()
      .size_full()
      .track_focus(this.keyboard)
      .on_key_down((event) => this.early?.push(event));
  }
}
