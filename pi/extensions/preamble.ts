// Replace the opening sentence of the system prompt and drop its docs section,
// so the prompt never names the harness. pi lets no extension replace the
// preamble section, so this edits the text and returns the whole prompt.
// It keeps the tools and rules sections that pi generates, but drops each
// rule line that names the PI_ environment variables. pi adds one when the
// bash tool is active. The variables stay in the environment.
// A custom prompt, such as the body of an agent, has no preamble of pi and
// stays as it is. The exception is the header that the pi-subagents package
// puts at the start of the prompt of each replace-mode agent (Explore, review,
// Plan). "You are a pi coding agent sub-agent." becomes "You are a sub-agent.".
// Without that header, the prompt stays unchanged.

const PREAMBLE =
  "You are an expert coding assistant. You help users by reading files, executing commands, editing code, and writing new files.";

const SUB_AGENT_HEADER = "You are a sub-agent.";

const PI_SUB_AGENT_HEADER = /^(<active_agent name="[^"\n]*"\/>\n\n)You are a pi coding agent sub-agent\./;
const PI_PREAMBLE = /^You are a coding assistant running inside pi, a coding agent harness\.[^\n]*/;
const DOCS_SECTION = /\n*<docs>[\s\S]*?<\/docs>/;
const NAMES_PI = /^[^\n]*\bpi\b/;
const RULES_SECTION = /<rules>[\s\S]*?<\/rules>/;
const PI_VARIABLES_RULES = /\n- [^\n]*\bPI_[^\n]*/g;

export default function (pi) {
  pi.on("before_agent_start", async (event) => {
    const prompt = event.systemPrompt;
    if (PI_SUB_AGENT_HEADER.test(prompt)) return { systemPrompt: prompt.replace(PI_SUB_AGENT_HEADER, `$1${SUB_AGENT_HEADER}`) };
    if (!PI_PREAMBLE.test(prompt)) {
      if (!NAMES_PI.test(prompt)) return {};
      throw new Error("preamble extension: the preamble of pi was not found, so its wording changed.");
    }
    return { systemPrompt: withoutPiVariablesRules(prompt.replace(PI_PREAMBLE, PREAMBLE).replace(DOCS_SECTION, "")) };
  });
}

function withoutPiVariablesRules(prompt) {
  return prompt.replace(RULES_SECTION, (rules) => rules.replace(PI_VARIABLES_RULES, ""));
}
