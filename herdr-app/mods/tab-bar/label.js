export function tabLabel(tab) {
  return tab.named ? `${tab.index} ${tab.name}` : `${tab.index}`;
}
