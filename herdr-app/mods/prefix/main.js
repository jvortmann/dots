import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { checking, closeOverlay, focused, hc, nextCommand, props, run, setShared, shared, spaces, theme } from "herdr";
import { actionFor, helpGroups, lastTab, rememberTab } from "./keymap.js";

const HISTORY = "prefix.tabs";
const CTRL_A = { key: "a", modifiers: { control: true } };

export default class Prefix extends View {
  init(_props, cx) {
    this.handle = cx.focus_handle();
    this.handle.focus();
    this.last = recallLastTab();
    // The mod-specific key binding beats the global opener while we're open.
    cx.spawn(async (cx) => {
      for (;;) {
        if ((await nextCommand()) === "last-tab") this.act(actionFor(CTRL_A, this.last), cx);
      }
    });
  }

  dismiss() {
    closeOverlay(props().overlay);
  }

  send(key, cx) {
    const terminal = focused()?.terminal;
    if (!terminal) return this.dismiss();
    // hc starts its subprocess at the call, before closing cancels this view's tasks.
    const pending = hc(["keys", terminal, key]);
    cx.spawn(async () => {
      const result = await pending;
      if (result.code !== 0) console.log(`prefix: ${result.stderr}`);
    });
    this.dismiss();
  }

  act(action, cx) {
    if (action.send) return this.send(action.send, cx);
    this.dismiss();
    if (action.run) run(action.run, action.args);
  }

  key(e, cx) {
    cx.stop_propagation();
    this.act(actionFor(e, this.last), cx);
  }

  render() {
    const t = theme();
    return v_flex().id("prefix").track_focus(this.handle)
      .on_key_down((e, cx) => this.key(e, cx))
      .p(14).gap(8).bg(t.popover).text_color(t.foreground).text_size(12)
      .child(h_flex().justify_between().child(div().font_semibold().child("Ctrl+A · waiting for a key"))
        .child(div().text_color(t.muted).child("Esc cancel")))
      .child(h_flex().items_start().gap(16).children(helpGroups().map(({ title, rows }) =>
        v_flex().flex_1().child(div().h(20).text_color(t.muted).child(title))
          .children(rows.map(({ keys, label }) =>
            h_flex().h(20).flex_none().items_center().gap(8)
              .child(div().w(52).flex_none().text_color(t.accent).child(keys))
              .child(div().flex_1().child(label)))))));
  }
}

// The app has no last-tab command and no tab-change event, so the popup
// records the focused tab of each space each time it opens. A tab switch
// with no prefix press between two presses goes unseen.
function recallLastTab() {
  const here = focused();
  if (!here || checking()) return undefined;
  const stored = shared(HISTORY) ?? {};
  const history = rememberTab(stored, here, spaces().map(({ id }) => id));
  if (JSON.stringify(history) !== JSON.stringify(stored)) setShared(HISTORY, history);
  const open = spaces().find(({ id }) => id === here.space)?.tabs.map(({ id }) => id) ?? [];
  return lastTab(history, here, open);
}
