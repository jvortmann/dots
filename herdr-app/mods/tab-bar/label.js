export function tabLabel(tab, number) {
  return tab.named ? `${number} ${tab.name}` : `${number}`;
}
