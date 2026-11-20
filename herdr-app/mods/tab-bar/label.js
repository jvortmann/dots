export function tabText(tab, terminal) {
  return tab.named ? tab.name : (terminal?.foreground?.name ?? "");
}
