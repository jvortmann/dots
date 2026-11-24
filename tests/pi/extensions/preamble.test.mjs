import assert from "node:assert/strict";
import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { test } from "node:test";
import extension from "../../../pi/extensions/preamble.ts";
import { PI_DIR } from "./pi-packages.mjs";

const SUBAGENTS_DIR = `${homedir()}/.config/pi/npm/node_modules/@tintinweb/pi-subagents`;
const skip = !existsSync(`${PI_DIR}/dist/core/system-prompt.js`) && "needs pi installed with mise";
const skipSubagents = skip || (!existsSync(`${SUBAGENTS_DIR}/dist/prompts.js`) && "needs the subagents package installed");
const { buildSystemPrompt } = skip ? {} : await import(`${PI_DIR}/dist/core/system-prompt.js`);
const { bashToolSystemPromptContribution: bash } = skip ? {} : await import(`${PI_DIR}/dist/core/tools/bash.js`);
const { buildAgentPrompt } = skipSubagents ? {} : await import(`${SUBAGENTS_DIR}/dist/prompts.js`);

test("the prompt never names pi", { skip }, async () => {
  assert.doesNotMatch(await promptAfterTheHook(), /\b[Pp]i\b/);
});

test("the prompt opens with our preamble", { skip }, async () => {
  assert.match(await promptAfterTheHook(), /^You are an expert coding assistant\./);
});

test("the prompt keeps the tools and the rules", { skip }, async () => {
  const prompt = await promptAfterTheHook();
  assert.ok(prompt.includes("<tools>"), prompt);
  assert.ok(prompt.includes("- read: Read files"), prompt);
  assert.ok(prompt.includes("<rules>"), prompt);
  assert.ok(prompt.includes("- Run the suite first"), prompt);
});

test("the prompt drops the docs section", { skip }, async () => {
  assert.equal((await promptAfterTheHook()).includes("<docs>"), false);
});

test("the prompt drops the rule on pi variables", { skip }, async () => {
  assert.equal((await promptAfterTheHook()).includes("PI_"), false);
});

test("the prompt drops a reworded rule on pi variables", { skip }, async () => {
  const prompt = await runTheHook({ bashRule: "Read PI_MODEL to learn the model." });
  assert.equal(prompt.includes("PI_"), false);
  assert.ok(prompt.includes("- Run the suite first"), prompt);
});

test("the prompt keeps a rule on an api key", { skip }, async () => {
  const prompt = await runTheHook({ bashRule: "Set OPENAI_API_KEY first." });
  assert.ok(prompt.includes("- Set OPENAI_API_KEY first."), prompt);
});

test("the prompt keeps project instructions on pi variables", { skip }, async () => {
  const prompt = await runTheHook({ instructions: "- Set PI_CODING_AGENT_DIR first." });
  assert.ok(prompt.includes("- Set PI_CODING_AGENT_DIR first."), prompt);
});

test("the prompt keeps the rules without the bash tool", { skip }, async () => {
  const prompt = await runTheHook({ tools: "read" });
  assert.ok(prompt.includes("- Run the suite first"), prompt);
  assert.ok(prompt.includes("- Be concise in your responses"), prompt);
});

test("the hook fails when the preamble of pi changes its words", { skip }, async () => {
  const output = await runTheHook({ otherPreamble: "You are an agent that runs in pi, a harness." });
  assert.ok(output.includes("preamble"), output);
  assert.ok(output.includes("not found"), output);
});

test("the hook leaves a custom prompt unchanged", { skip }, async () => {
  const output = await runTheHook({ otherPreamble: "# Review" });
  assert.match(output, /^# Review/);
  assert.equal(output.includes("not found"), false);
});

test("the prompt of a sub agent opens with our header", { skip: skipSubagents }, async () => {
  const prompt = await promptOfASubAgentAfterTheHook();
  assert.equal(prompt.split("\n").slice(0, 3).join("\n"), '<active_agent name="Explore"/>\n\nYou are a sub-agent.');
  assert.doesNotMatch(prompt, /\b[Pp]i\b/);
});

test("the hook leaves a sub agent prompt with another header unchanged", { skip: skipSubagents }, async () => {
  const output = await promptOfASubAgentAfterTheHook("You are a pi sub-agent.");
  assert.ok(output.includes('<active_agent name="Explore"/>\n\nYou are a pi sub-agent.\n'), output);
  assert.equal(output.includes("not found"), false);
});

// The default prompt that pi builds, with the read and bash tools and one
// extension rule, run through the before_agent_start handler of the extension.
function promptAfterTheHook() {
  return runTheHook();
}

// The prompt of the Explore agent, which replaces the prompt of pi, as the
// subagents package builds it, run through the hook. The header replaces the
// header of the package before the hook runs, when set.
function promptOfASubAgentAfterTheHook(header = "") {
  return runTheHook({ otherPreamble: header, agentBody: "# Explore\nFind the code." });
}

// otherPreamble replaces the first line that opens with "You are" before the
// hook runs, when set. That is the preamble sentence of pi, or the header of
// an agent. tools is the comma-separated list of tools. bashRule replaces the
// rule of the bash tool, when set. instructions is the content of one project
// instructions file, when set. agentBody is the body of an agent in replace
// mode, when set. The subagents package then builds the prompt that pi uses in
// place of its own preamble. Gives the prompt after the hook, or the message
// of its error.
async function runTheHook({ otherPreamble = "", tools = "read,bash", bashRule = "", instructions = "", agentBody = "" } = {}) {
  const customPrompt = agentBody
    ? buildAgentPrompt({ name: "Explore", promptMode: "replace", systemPrompt: agentBody }, "/work", { isGitRepo: false, platform: "darwin" })
    : undefined;
  let prompt = buildSystemPrompt({
    customPrompt,
    selectedTools: tools.split(","),
    toolSnippets: { read: "Read files", bash: bash.snippet },
    toolGuidelines: tools.includes("bash") ? { bash: bashRule ? [bashRule] : bash.guidelines } : {},
    promptGuidelines: ["Run the suite first"],
    cwd: "/work",
    contextFiles: instructions ? [{ path: "AGENTS.md", content: instructions }] : [],
    skills: [],
  });
  if (otherPreamble) prompt = prompt.replace(/^You are[^\n]*/m, otherPreamble);
  const handlers = {};
  extension({ on: (name, handler) => { handlers[name] = handler; } });
  const stderr = [];
  const write = process.stderr.write;
  process.stderr.write = (chunk) => stderr.push(String(chunk));
  let result;
  try {
    result = handlers.before_agent_start({ systemPrompt: prompt, systemPromptOptions: {} }, {});
  } finally {
    process.stderr.write = write;
  }
  try {
    return ((await result).systemPrompt ?? prompt) + stderr.join("");
  } catch (error) {
    return String(error.message) + stderr.join("");
  }
}
