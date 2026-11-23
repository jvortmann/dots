// Decides what a ctrl-h/j/k/l key does. When the terminal has the label
// nvim.server, the key goes to that nvim server, and the pane moves when the
// send fails. hc keys waits about 3 seconds of quiet after a key of the
// person, so only nvim with no label gets its key from hc keys. Any other
// program moves the pane. So does copy mode, which shows its nvim with
// terminal.show.

const KEYS = { left: "ctrl+h", down: "ctrl+j", up: "ctrl+k", right: "ctrl+l" };
const NVIM_KEYS = { left: "<C-h>", down: "<C-j>", up: "<C-k>", right: "<C-l>" };
const NVIM = "/opt/homebrew/bin/nvim";

export function route(direction, focus, panes, terminals, home) {
  const go = { run: ["pane.go", { direction }] };
  const pane = panes.find((p) => p.pane === focus?.pane);
  if (!pane || focus.shown) return go;
  const server = terminals.find((t) => t.address === focus.terminal)?.labels?.["nvim.server"];
  if (server) return { exec: [NVIM, ["--server", server, "--remote-send", NVIM_KEYS[direction]]], failed: go.run };
  if (pane.program?.key === "nvim") return { exec: [`${home}/.local/bin/hc`, ["keys", focus.terminal, KEYS[direction]]] };
  return go;
}
