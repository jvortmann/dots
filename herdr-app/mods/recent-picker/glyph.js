// The table gives a glyph color for drawing on a tile, and a mod draws no tile.
// The pi glyph takes the theme violet. Another glyph takes its tile color when
// that reaches 3:1 on the background. Else it takes the color or the tile,
// whichever stands out more.
const THEME_COLORS = { pi: "ansi13" };

export function glyphColor(program, background, fallback, theme = {}) {
  const own = theme[THEME_COLORS[program.key]];
  if (own) return own;
  const choices = [program.color, program.tile].filter(Boolean);
  if (!choices.length) return fallback;
  if (program.tile && contrast(program.tile, background) >= 3) return program.tile;
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
