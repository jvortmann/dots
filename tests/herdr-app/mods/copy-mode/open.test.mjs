import assert from "node:assert/strict";
import { test } from "node:test";
import { openCopyMode, Standby } from "../../../../herdr-app/mods/copy-mode/open.js";

// A warm nvim, and a time limit that never ends.
const warm = (address, server) => ({ address, state: "live", labels: { "copy-mode.standby": server } });
const never = new Promise(() => {});

test("shows the warm nvim in the pane once it has opened copy mode", async () => {
  assert.equal(
    await scenario(({ app }) => openCopyMode(app, { source: "t7", pane: "p1", nvim: warm("t9", "/run/nvim.0") })),
    String.raw`["exec","nvim","--server","/run/nvim.0","--remote-expr","v:lua.copy_mode_open(\"t7\", {\"fg\":\"#002b36\",\"bg\":\"#b58900\"})"]
["terminal.show",{"terminal":"t9","pane":"p1"}]`,
  );
});

test("draws the selection in colors 8 and 3 of the theme of the app", async () => {
  const exec = await scenario(async (world) => {
    world.palette = { ansi3: "#123456", ansi8: "#654321", ansi4: "#000000", foreground: "#ffffff" };
    await openCopyMode(world.app, { source: "t7", pane: "p1", nvim: warm("t9", "/run/nvim.0") });
  }, startsWith('["exec"'));
  assert.ok(exec.includes(String.raw`v:lua.copy_mode_open(\"t7\", {\"fg\":\"#654321\",\"bg\":\"#123456\"})`), exec);
});

test("shows nothing and says why when nvim cannot open copy mode", async () => {
  assert.equal(
    await scenario(async (world) => {
      world.results.exec = { code: 2, stdout: "", stderr: "Lua: Vim:E5108: Lua: cannot read t7\nstack traceback:\n" };
      await openCopyMode(world.app, { source: "t7", pane: "p1", nvim: warm("t9", "/run/nvim.0") });
    }, not(startsWith('["exec"', '["hc"'))),
    '["error","Lua: Vim:E5108: Lua: cannot read t7"]',
  );
});

test("ends the warm nvim that cannot open copy mode", async () => {
  assert.equal(
    await scenario(async (world) => {
      world.results.exec = { code: 2, stdout: "", stderr: "E247: Failed to connect" };
      await openCopyMode(world.app, { source: "t7", pane: "p1", nvim: warm("t9", "/run/nvim.0") });
    }, startsWith('["hc"')),
    '["hc","kill","t9"]',
  );
});

test("says how nvim ended when it gives no reason", async () => {
  assert.equal(
    await scenario(async (world) => {
      world.results.exec = { code: 2, stdout: "", stderr: "" };
      await openCopyMode(world.app, { source: "t7", pane: "p1", nvim: warm("t9", "/run/nvim.0") });
    }, startsWith('["error"')),
    '["error","nvim exited with code 2"]',
  );
});

test("takes the warm nvim that tells where its server listens", async () => {
  assert.equal(
    await scenario(async (world) => {
      world.listed = [{ address: "t3", state: "live", labels: {} }, warm("t9", "/run/nvim.0")];
      const nvim = await new Standby(world.app, "/v.sh").take(never);
      world.calls.push(["took", nvim?.address ?? null]);
    }),
    '["took","t9"]',
  );
});

test("takes each warm nvim once", async () => {
  assert.equal(
    await scenario(async (world) => {
      world.listed = [warm("t9", "/run/nvim.0")];
      const standby = new Standby(world.app, "/v.sh");
      await standby.take(never);
      await standby.take(Promise.resolve());
    }),
    '["error","no warm nvim is ready for copy mode"]',
  );
});

test("waits for a warm nvim that becomes ready after the key", async () => {
  assert.equal(
    await scenario(async (world) => {
      const standby = new Standby(world.app, "/v.sh");
      const taken = standby.take(never);
      world.listed = [warm("t9", "/run/nvim.0")];
      standby.ready();
      world.calls.push(["took", (await taken).address]);
    }),
    '["took","t9"]',
  );
});

// The time limit of the take ends right after the render that lists the next
// warm nvim, so the test does not wait on the clock.
test("opens again right after q once the next warm nvim is ready", async () => {
  assert.equal(
    await scenario(async (world) => {
      const standby = new Standby(world.app, "/v.sh");
      const render = () => standby.shouldStart() && standby.start();
      world.listed = [warm("t8", "/run/nvim.1")];
      await render();
      await standby.take(never);
      await render();
      world.listed = [];
      await render();
      await render();
      const limit = Promise.withResolvers();
      const taken = standby.take(limit.promise);
      world.listed = [warm("t9", "/run/nvim.0")];
      await render();
      limit.resolve();
      world.calls.push(["took", (await taken).address]);
    }, not(startsWith('["hc"'))),
    '["took","t9"]',
  );
});

test("starts a warm nvim when none is ready", async () => {
  assert.equal(
    await scenario(async ({ app }) => {
      const standby = new Standby(app, "/v.sh");
      if (standby.shouldStart()) await standby.start();
    }),
    '["hc","run","--bg","--json","--no-parent","--no-notify","--rm","--cwd","/home","--","/bin/sh","/v.sh"]',
  );
});

test("starts one warm nvim at a time", async () => {
  assert.equal(
    await scenario(async (world) => {
      const standby = new Standby(world.app, "/v.sh");
      world.calls.push(["should start", standby.shouldStart(), standby.shouldStart()]);
    }),
    '["should start",true,false]',
  );
});

test("starts the next warm nvim once the last one is taken", async () => {
  assert.equal(
    await scenario(async (world) => {
      const standby = new Standby(world.app, "/v.sh");
      standby.shouldStart();
      world.listed = [warm("t9", "/run/nvim.0")];
      await standby.take(never);
      world.calls.push(["should start", standby.shouldStart()]);
    }),
    '["should start",true]',
  );
});

test("starts again when no warm nvim became ready in time", async () => {
  assert.equal(
    await scenario(async (world) => {
      const standby = new Standby(world.app, "/v.sh");
      standby.shouldStart();
      await standby.take(Promise.resolve()).catch(() => {});
      world.calls.push(["should start", standby.shouldStart()]);
    }),
    '["should start",true]',
  );
});

test("says why a warm nvim cannot start and starts again", async () => {
  assert.equal(
    await scenario(async (world) => {
      world.results.hc = { code: 1, stdout: "", stderr: "the core is down" };
      const standby = new Standby(world.app, "/v.sh");
      standby.shouldStart();
      await standby.start().catch((error) => world.calls.push(["error", error.message]));
      world.calls.push(["should start", standby.shouldStart()]);
    }, not(startsWith('["hc"'))),
    '["error","the core is down"]\n["should start",true]',
  );
});

test("closing ends the warm nvims", async () => {
  assert.equal(
    await scenario(async (world) => {
      const standby = new Standby(world.app, "/v.sh");
      standby.shouldStart();
      await standby.start();
      world.listed = [warm("t8", "/run/nvim.1"), { address: "t3", state: "live", labels: {} }];
      await standby.close();
    }, startsWith('["hc","kill"')),
    '["hc","kill","t8"]\n["hc","kill","t9"]',
  );
});

test("closing ends a warm nvim that was not ready in time", async () => {
  assert.equal(
    await scenario(async (world) => {
      const standby = new Standby(world.app, "/v.sh");
      world.results.hc = { code: 0, stdout: '{"address":"t8"}', stderr: "" };
      standby.shouldStart();
      await standby.start();
      await standby.take(Promise.resolve()).catch(() => {});
      world.results.hc = { code: 0, stdout: '{"address":"t9"}', stderr: "" };
      standby.shouldStart();
      await standby.start();
      await standby.close();
    }, startsWith('["hc","kill"')),
    '["hc","kill","t8"]\n["hc","kill","t9"]',
  );
});

// Runs the steps with a stand-in app in world.app. The app lists
// world.listed and gives world.palette as its theme. Its exec and hc return
// world.results.exec and world.results.hc. The scenario returns each call
// and each error as one JSON line, and only the lines that pass keep.
// The app answers at once, so steps that are still open at the next turn of
// the event loop never end. node --test hangs on such a promise, so the
// scenario then adds the line ["stuck"].
async function scenario(steps, keep = () => true) {
  const stuck = Symbol("stuck");
  const drained = new Promise((end) => setImmediate(end, stuck));
  const calls = [];
  const world = {
    calls,
    listed: [],
    palette: { ansi3: "#b58900", ansi8: "#002b36" },
    results: { exec: { code: 0, stdout: "", stderr: "" }, hc: { code: 0, stdout: '{"address":"t9"}', stderr: "" } },
  };
  world.app = {
    home: "/home",
    exec: async (command, args) => (calls.push(["exec", command, ...args]), world.results.exec),
    hc: async (args) => (calls.push(["hc", ...args]), world.results.hc),
    run: (name, args) => calls.push([name, args]),
    terminals: () => world.listed,
    theme: () => world.palette,
  };
  try {
    if ((await Promise.race([steps(world), drained])) === stuck) calls.push(["stuck"]);
  } catch (error) {
    calls.push(["error", error.message]);
  }
  return calls.map((call) => JSON.stringify(call)).filter(keep).join("\n");
}

function startsWith(...prefixes) {
  return (line) => prefixes.some((prefix) => line.startsWith(prefix));
}

function not(accepts) {
  return (line) => !accepts(line);
}
