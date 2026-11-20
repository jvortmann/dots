export function tabLabel(tab, number, terminal) {
  if (tab.named) return `${number} ${tab.name}`;
  const process = terminal?.foreground?.name;
  return process ? `${number} ${process}` : `${number}`;
}

export function tabFolder(tab, folder) {
  return tab.named ? folder : "";
}
