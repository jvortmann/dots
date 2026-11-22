export function quarter(color) {
  const alpha = color.length === 9 ? parseInt(color.slice(7), 16) : 255;
  return color.slice(0, 7) + Math.round(alpha / 4).toString(16).padStart(2, "0");
}
