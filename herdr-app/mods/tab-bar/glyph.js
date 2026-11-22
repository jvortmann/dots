// The table gives a glyph color for drawing on its tile. A mod draws no tile,
// so the glyph takes its color or its tile, whichever stands out more.
export function glyphColor(program, background, fallback) {
  const choices = [program.color, program.tile].filter(Boolean);
  if (!choices.length) return fallback;
  return choices.reduce((best, c) => (contrast(c, background) > contrast(best, background) ? c : best));
}

function contrast(a, b) {
  const [light, dark] = [luminance(a), luminance(b)].sort((x, y) => y - x);
  return (light + 0.05) / (dark + 0.05);
}

function luminance(hex) {
  const [r, g, b] = [1, 3, 5].map((i) => parseInt(hex.slice(i, i + 2), 16) / 255).map((v) => (v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4));
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}
