// Replace the opening sentence of the system prompt and drop its docs section,
// so the prompt never names the harness. pi lets no extension replace the
// preamble section, so this edits the text and returns the whole prompt.
// It keeps the tools and rules sections that pi generates. A custom prompt,
// such as the body of an agent, has no preamble of pi and stays as it is.

const PREAMBLE =
  "You are an expert coding assistant. You help users by reading files, executing commands, editing code, and writing new files.";

const PI_PREAMBLE = /^You are a coding assistant running inside pi, a coding agent harness\.[^\n]*/;
const DOCS_SECTION = /\n*<docs>[\s\S]*?<\/docs>/;
const NAMES_PI = /^[^\n]*\bpi\b/;

export default function (pi) {
  pi.on("before_agent_start", async (event) => {
    const prompt = event.systemPrompt;
    if (!PI_PREAMBLE.test(prompt)) {
      if (!NAMES_PI.test(prompt)) return {};
      throw new Error("preamble extension: the preamble of pi was not found, so its wording changed.");
    }
    return { systemPrompt: prompt.replace(PI_PREAMBLE, PREAMBLE).replace(DOCS_SECTION, "") };
  });
}
