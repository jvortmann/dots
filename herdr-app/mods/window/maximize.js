export function shouldMaximize(win) {
  return Boolean(win) && !win.maximized && !win.fullscreen;
}
