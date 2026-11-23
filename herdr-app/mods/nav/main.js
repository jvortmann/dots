// The nav mod: it takes nav.left, nav.down, nav.up and nav.right from
// keys.json, and does what route.js decides.
// It runs hc and nvim with exec, and not hc(). The hc() bridge of the app
// stalled 1.3 to 2.3 seconds after a pause in an earlier nav mod. exec needs
// the full path of a program, because an app that launchd starts has no login
// PATH.

import { View, div } from "gpui-kit";
import { exec, focused, home, nextCommand, notify, panes, run, terminals } from "herdr";
import { route } from "./route.js";

export default class Nav extends View {
  init(_props, cx) {
    cx.spawn(async () => {
      for (;;) {
        const command = await nextCommand();
        try {
          const step = route(command, focused(), panes(), terminals(), home());
          if (step.failed) {
            const sent = await exec(...step.exec, { timeout: 500 }).catch(() => ({ code: -1 }));
            if (sent.code !== 0) run(...step.failed);
          } else if (step.exec) {
            const sent = await exec(...step.exec, { timeout: 5000 });
            if (sent.code !== 0) throw new Error(sent.stderr.trim() || `hc keys exited with code ${sent.code}`);
          } else run(...step.run);
        } catch (error) {
          notify({ title: "Nav failed", body: String(error?.message ?? error), level: "error" });
        }
      }
    });
  }

  render() {
    return div();
  }
}
