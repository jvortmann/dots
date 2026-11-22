export const PI_ICON = "mods/tab-bar/pi.svg";

// Write only when the file differs, and only over the text read here
// (expected). So a change by another writer is not lost. When another window
// wrote the same icon first, the failed write counts as done.
export async function syncPiIcon(files, path, color) {
  const want = piIcon(color);
  const have = await files.readTextFile(path);
  if (have === want) return;
  try {
    await files.writeTextFile(path, want, have);
  } catch (error) {
    if ((await files.readTextFile(path)) !== want) throw error;
  }
}

export function piIcon(color) {
  return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 800">
  <path fill="${color}" fill-rule="evenodd" d="
    M165.29 165.29
    H517.36
    V400
    H400
    V517.36
    H282.65
    V634.72
    H165.29
    Z
    M282.65 282.65
    V400
    H400
    V282.65
    Z
  "/>
  <path fill="${color}" d="M517.36 400 H634.72 V634.72 H517.36 Z"/>
</svg>
`;
}
