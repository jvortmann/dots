// Nav: ctrl-h/j/k/l move between nvim windows and Herdr panes, as
// vim-tmux-navigator does in tmux. In nvim the key goes on to nvim. In other
// programs and in copy mode it moves the pane.

import { View, div } from "gpui-kit";
import { focused, hc, nextCommand, notify, panes, run } from "herdr";
import { route } from "./route.js";

export default class Nav extends View {
  init(_props, cx) {
    cx.spawn(async () => {
      for (;;) {
        const command = await nextCommand();
        try {
          const step = route(command, focused(), panes());
          if (step?.keys) {
            const sent = await hc(["keys", step.terminal, step.keys]);
            if (sent.code !== 0) throw new Error(sent.stderr);
          } else if (step?.go) run("pane.go", { direction: step.go });
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
