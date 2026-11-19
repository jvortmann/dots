// Copy mode: ctrl-a [ shows the text of the focused terminal, with its colors,
// in a read-only nvim in the same pane. The design comes from the tmux-compat
// mod of herdr-term (https://github.com/cristianoliveira/herdr-term).

import { View, div } from "gpui-kit";
import { appHome, checking, exec, focused, hc, home, nextCommand, notify, run, terminals } from "herdr";
import { Standby, openCopyMode } from "./open.js";

const app = {
  exec,
  hc,
  run,
  terminals,
  get home() {
    return home();
  },
};

export default class CopyMode extends View {
  init(_props, cx) {
    this.standby = new Standby(app, `${appHome()}/mods/copy-mode/view.sh`);
    cx.spawn(async (cx) => {
      for (;;) {
        if ((await nextCommand()) !== "open") continue;
        try {
          await this.open(cx);
        } catch (error) {
          fail(error);
        }
      }
    });
  }

  async open(cx) {
    const { terminal: source, pane, shown } = focused() ?? {};
    // Copy mode already shows in this pane.
    if (shown) return;
    if (!source || !pane) {
      notify({ title: "Copy mode", body: "Focus a terminal first.", level: "info" });
      return;
    }
    this.keepWarm(cx);
    const nvim = await this.standby.take(cx.sleep(3000));
    await openCopyMode(app, { source, pane, nvim });
  }

  // The app renders the mod again each time the terminals change.
  render(cx) {
    this.keepWarm(cx);
    return div().size_full();
  }

  keepWarm(cx) {
    if (checking() || !this.standby.shouldStart()) return;
    cx.spawn(async () => {
      try {
        await this.standby.start();
      } catch (error) {
        fail(error);
      }
    });
  }

  async close() {
    await this.standby.close();
  }
}

function fail(error) {
  notify({ title: "Copy mode failed", body: String(error?.message ?? error), level: "error" });
}
