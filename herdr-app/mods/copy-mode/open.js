// The steps that open copy mode, apart from the app, so that a test can run
// them. `app` holds the calls of the app that they use: hc, run, terminals
// and sleep (seconds).

// The show also gives the pane the keyboard. pane.focus would end the show, so
// only a failed open gives the keyboard back with it.
export async function openCopyMode(app, { source, pane, view, early }) {
  let address;
  try {
    address = await start(app, view, source);
  } catch (error) {
    app.run("pane.focus", { pane });
    throw error;
  }
  app.run("terminal.show", { terminal: address, pane });
  await replay(app, address, early);
}

// Starts nvim on the source terminal, and waits until the app knows the new
// terminal: terminal.show does nothing with a terminal it does not know yet.
async function start(app, view, source) {
  const result = await app.hc([
    "run", "--bg", "--json", "--no-parent", "--no-notify", "--rm", "--cwd", app.home,
    "--", "/bin/sh", view, source,
  ]);
  if (result.code !== 0) throw new Error(result.stderr || result.stdout);
  const address = JSON.parse(result.stdout).address;
  for (let waited = 0; !app.terminals().some((t) => t.address === address); waited += 20) {
    if (waited >= 3000) {
      app.run("terminal.kill", { terminal: address });
      throw new Error(`the app did not see ${address} start`);
    }
    await app.sleep(0.02);
  }
  return address;
}

// Sends the early keys to nvim in order, also the ones typed while it sends.
async function replay(app, address, early) {
  for (let sent = 0; sent < early.length; ) {
    const keys = early.slice(sent).map(keyName).filter(Boolean);
    sent = early.length;
    if (keys.length === 0) continue;
    const result = await app.hc(["keys", address, ...keys]);
    if (result.code !== 0) throw new Error(result.stderr || result.stdout);
  }
}

const NAMED_KEYS = { escape: "esc", enter: "enter", space: "space", up: "up", down: "down", left: "left", right: "right" };

// The name hc keys takes for a key event, or null for a key it may not know.
function keyName(event) {
  if (/^[A-Za-z0-9/]$/.test(event.key_char ?? "")) return event.key_char;
  if (NAMED_KEYS[event.keystroke]) return NAMED_KEYS[event.keystroke];
  if (/^ctrl-[a-z]$/.test(event.keystroke)) return event.keystroke.replace("-", "+");
  return null;
}
