// The panel of the layout, found and toggled by the ids of the stock tabs mod: panel, panel-body and changes.
export function changesShown(root) {
  const panel = find(root, "panel");
  return Boolean(panel && !panel.hidden && find(root, "panel-body")?.active === "changes");
}

export function toggleChanges(root) {
  if (changesShown(root)) return [["layout.hide", { id: "panel" }]];
  return [["layout.select", { stack: "panel-body", child: "changes" }], ["layout.show", { id: "panel" }]];
}

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}
