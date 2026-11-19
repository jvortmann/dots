// The steps that open copy mode, apart from the app, so that a test can run
// them. `app` holds the calls of the app that they use: exec, hc, run,
// terminals and home.

// The label in which a warm nvim gives the address of its server.
const LABEL = "copy-mode.standby";

// The warm nvim draws copy mode of the source terminal, and only then the app
// shows it in the pane. So the pane keeps the keyboard and its focus accent.
export async function openCopyMode(app, { source, pane, nvim }) {
  const result = await app.exec("nvim", ["--server", nvim.labels[LABEL], "--remote-expr", `v:lua.copy_mode_open(${JSON.stringify(source)})`]);
  if (result.code !== 0) {
    await app.hc(["kill", nvim.address]);
    throw new Error((result.stderr || result.stdout || `nvim exited with code ${result.code}`).split("\n")[0]);
  }
  app.run("terminal.show", { terminal: nvim.address, pane });
}

export class Standby {
  constructor(app, view) {
    this.app = app;
    this.view = view;
    this.used = new Set();
    this.started = new Set();
  }

  // Takes the warm nvim for one open. When none is ready, it waits for one
  // until the promise `limit` ends.
  async take(limit) {
    const nvim = this.ready() ?? (await Promise.race([new Promise((found) => (this.waiting = found)), limit]));
    this.waiting = null;
    if (!nvim) {
      this.starting = false;
      throw new Error("no warm nvim is ready for copy mode");
    }
    this.used.add(nvim.address);
    return nvim;
  }

  // Returns a ready warm nvim, and gives it to an open that waits. The mod
  // calls it each time the terminals change.
  ready() {
    const [nvim] = this.warm();
    if (nvim) {
      this.starting = false;
      this.waiting?.(nvim);
    }
    return nvim;
  }

  // True when the mod must start a warm nvim, because none is ready or
  // starting. It then marks one as starting.
  shouldStart() {
    if (this.starting || this.ready()) return false;
    return (this.starting = true);
  }

  // Starts a warm nvim. It has no space label, no tab label and no parent, so
  // no tab, list or picker of the app shows it.
  async start() {
    const result = await this.app.hc(["run", "--bg", "--json", "--no-parent", "--no-notify", "--rm", "--cwd", this.app.home, "--", "/bin/sh", this.view]);
    if (result.code !== 0) {
      this.starting = false;
      throw new Error(result.stderr || result.stdout);
    }
    this.started.add(JSON.parse(result.stdout).address);
  }

  // Ends the warm nvims: the ready ones, and the ones it started that no open
  // took, also when they are not ready yet.
  async close() {
    const warm = new Set([...this.warm().map((t) => t.address), ...[...this.started].filter((a) => !this.used.has(a))]);
    for (const address of warm) await this.app.hc(["kill", address]);
  }

  warm() {
    return this.app.terminals().filter((t) => t.state === "live" && t.labels?.[LABEL] && !this.used.has(t.address));
  }
}
