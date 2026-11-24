import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import { test } from "node:test";
import { piIcon, syncPiIcon } from "../../../../herdr-app/mods/tab-bar/pi-icon.js";

const STOCK_PI = new URL("../../../../herdr-app/icons/pi.svg", import.meta.url);

test("draws the shape of the stock pi icon in the color it gets", { skip: !existsSync(STOCK_PI) && "the app has not written its icons yet" }, () => {
  const stock = readFileSync(STOCK_PI, "utf8").replaceAll("#fff", "#123456").replace(/\n+$/, "");
  assert.equal(piIcon("#123456").trimEnd(), stock);
});

test("writes the icon in the color it gets when there is no icon yet", async () => {
  const disk = standIn();
  await syncPiIcon(disk.files, "/app/pi.svg", "#123456");
  assert.equal(disk.printed(), '["write","/app/pi.svg","#123456",null]');
});

test("writes nothing when the icon already has the color", async () => {
  const disk = standIn(piIcon("#123456"));
  await syncPiIcon(disk.files, "/app/pi.svg", "#123456");
  assert.equal(disk.printed(), "");
});

test("replaces an icon of another color only if nothing changed it since the read", async () => {
  const disk = standIn(piIcon("#654321"));
  await syncPiIcon(disk.files, "/app/pi.svg", "#123456");
  assert.equal(disk.printed(), '["write","/app/pi.svg","#123456","#654321"]');
});

test("takes the icon that another window wrote first as written", async () => {
  const disk = standIn();
  disk.files.writeTextFile = async (path, text) => {
    disk.file = text;
    throw new Error("stale snapshot");
  };
  assert.equal(await outcome(syncPiIcon(disk.files, "/app/pi.svg", "#123456")), "written");
});

test("reports a write that fails while the icon keeps another color", async () => {
  const disk = standIn();
  disk.files.writeTextFile = async () => {
    throw new Error("stale snapshot");
  };
  assert.equal(await outcome(syncPiIcon(disk.files, "/app/pi.svg", "#123456")), "stale snapshot");
});

// Stand-in file calls. readTextFile gives the file. printed() gives each write
// as one JSON line, with the color of the icon it writes in place of its text.
function standIn(file = null) {
  const disk = { file, writes: [] };
  disk.files = {
    readTextFile: async () => disk.file,
    writeTextFile: async (path, text, expected) => disk.writes.push(["write", path, colorOf(text), expected === null ? null : colorOf(expected)]),
  };
  disk.printed = () => disk.writes.map((w) => JSON.stringify(w)).join("\n");
  return disk;
}

function colorOf(text) {
  return text.match(/fill="([^"]*)"/)?.[1] ?? text;
}

function outcome(sync) {
  return sync.then(
    () => "written",
    (e) => e.message,
  );
}
