// A theme color at a share of its strength. A color with an alpha of its own
// keeps that share of its alpha, so a faint theme color stays faint.
export function alpha(color, share) {
  const long = color.length === 4 ? `#${[...color.slice(1)].map((c) => c + c).join("")}` : color;
  const own = long.length === 9 ? parseInt(long.slice(7), 16) : 255;
  return long.slice(0, 7) + Math.round(own * share).toString(16).padStart(2, "0");
}
