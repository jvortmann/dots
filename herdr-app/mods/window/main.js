// The window: the app opens maximized, below the menu bar.

import { View, div } from "gpui-kit";
import { checking, run, window as win } from "herdr";
import { shouldMaximize } from "./maximize.js";

export default class Window extends View {
  init() {
    // window.maximize toggles, so it runs only on a window that is not maximized.
    if (!checking() && shouldMaximize(win())) run("window.maximize");
  }

  render() {
    return div();
  }
}
