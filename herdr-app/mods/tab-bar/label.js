export function tabText(tab, terminal) {
  return tab.named ? tab.name : (terminal?.foreground?.name ?? "");
}

export function tabFolder(tab, folder) {
  return tab.named ? folder : "";
}
