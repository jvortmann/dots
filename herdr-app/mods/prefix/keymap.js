export const BINDINGS = [
  ["c", "New tab", "tab.new"],
];

export function actionFor(event) {
  const { control, alt, platform } = event.modifiers;
  if (control && event.key === "a") return { send: "ctrl+a" };
  const plain = !control && !alt && !platform;
  const binding = plain && BINDINGS.find(([key]) => key === event.key_char);
  if (!binding) return { close: true };
  const [, , command, args = {}] = binding;
  return { run: command, args };
}
