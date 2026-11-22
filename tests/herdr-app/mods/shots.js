export function parseShot(shot) {
  return shot.split(" ").filter(Boolean).map((space) => {
    const [name, tabs] = space.split(":");
    return { ...item(name), tabs: tabs.split(",").filter(Boolean).map(item) };
  });
}

function item(name) {
  return { id: name.replace("*", ""), active: name.startsWith("*") };
}
