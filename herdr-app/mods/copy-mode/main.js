// PROBE (temporary, not for a commit): terminal.show of an hc run nvim
// terminal in the focused pane. Logs to shared key copy-mode.probe.

import { View, div } from "gpui-kit";
import { focused, hc, exec, appHome, home, nextCommand, notify, props, run, shared, setShared } from "herdr";

export default class CopyMode extends View {
  init(_props, cx) {
    this.terminal = props()?.terminal;
    if (this.terminal) return;
    setShared("copy-mode.probe", []);
    cx.spawn(async () => {
      for (;;) {
        const command = await nextCommand();
        try {
          if (command === "open") await this.open();
          else if (command === "back") await this.back();
        } catch (error) {
          this.log("error", String(error?.message ?? error));
        }
      }
    });
  }

  log(what, value) {
    const list = shared("copy-mode.probe") ?? [];
    list.push({ at: Date.now(), what, value });
    setShared("copy-mode.probe", list);
  }

  async size(address) {
    if (!address) return null;
    const r = await hc(["get", "--json", address]);
    if (r.code !== 0) return { code: r.code, err: r.stderr.slice(0, 200) };
    const j = JSON.parse(r.stdout);
    return { address, cols: j.cols, rows: j.rows, state: j.state, exit: j.exit_code };
  }

  pick(f) {
    return f && { space: f.space, tab: f.tab, pane: f.pane, terminal: f.terminal, shown: f.shown };
  }

  async open() {
    const f = focused();
    this.log("open:focused", this.pick(f));
    const source = f?.terminal;
    if (!source) return;
    this.source = source;
    this.log("open:source", await this.size(source));
    const view = `${appHome()}/mods/copy-mode/view.sh`;
    const result = await hc([
      "run", "--bg", "--json", "--no-parent", "--no-notify", "--rm", "--cwd", home(),
      "--", "/bin/sh", view, source,
    ]);
    const address = result.code === 0 ? JSON.parse(result.stdout).address : null;
    this.log("open:run", { code: result.code, address, err: result.stderr.slice(0, 200) });
    if (!address) return;
    this.shown = address;
    run("terminal.show", { terminal: address });
    await exec("sleep", ["0.6"]);
    this.log("open:after-show", this.pick(focused()));
    this.log("open:sizes", { source: await this.size(source), shown: await this.size(address) });
    this.watch(address, source);
  }

  async watch(address, source) {
    for (;;) {
      const r = await hc(["wait", "--json", address]);
      let j = null;
      try { j = JSON.parse(r.stdout); } catch (_) {}
      if (r.code !== 0 || j?.ended) {
        this.log("exit:wait", { code: r.code, out: r.stdout.slice(0, 200), err: r.stderr.slice(0, 200) });
        break;
      }
    }
    this.log("exit:focused-now", this.pick(focused()));
    await exec("sleep", ["0.6"]);
    const f = focused();
    this.log("exit:focused-later", this.pick(f));
    this.log("exit:sizes", { source: await this.size(source), shown: await this.size(address) });
    if (f?.shown === address) {
      run("terminal.show", {});
      await exec("sleep", ["0.6"]);
      this.log("exit:after-restore", this.pick(focused()));
    }
    const ls = await hc(["ls", "--all", "--json"]);
    this.log("exit:ls", ls.stdout.slice(0, 1500));
  }

  async back() {
    this.log("back:focused", this.pick(focused()));
    run("terminal.show", {});
    await exec("sleep", ["0.6"]);
    this.log("back:after-show", this.pick(focused()));
    this.log("back:sizes", { source: await this.size(this.source), shown: await this.size(this.shown) });
    if (this.shown) run("terminal.kill", { terminal: this.shown });
  }

  render() {
    return div();
  }
}
