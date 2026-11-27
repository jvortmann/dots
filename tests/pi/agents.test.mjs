import assert from "node:assert/strict";
import { existsSync } from "node:fs";
import { test } from "node:test";
import { resolvePiCodingAgent, SUBAGENTS_DIR } from "./extensions/pi-packages.mjs";

process.env.PI_CODING_AGENT_DIR = new URL("../../pi", import.meta.url).pathname;

const skip = (!resolvePiCodingAgent() && "needs pi installed with mise")
  || (!existsSync(`${SUBAGENTS_DIR}/dist/custom-agents.js`) && "needs the subagents package installed");
const { loadCustomAgents } = skip ? {} : await import(`${SUBAGENTS_DIR}/dist/custom-agents.js`);
const { preloadSkills } = skip ? {} : await import(`${SUBAGENTS_DIR}/dist/skill-loader.js`);

test("each skill that an agent preloads is found", { skip }, () => {
  const missing = [];
  for (const [name, agent] of agents()) {
    if (!Array.isArray(agent.skills)) continue;
    for (const skill of preloadSkills(agent.skills, import.meta.dirname)) {
      if (skill.content.startsWith(`(Skill "${skill.name}"`)) missing.push(`${name}: ${skill.name}`);
    }
  }
  assert.deepEqual(missing, []);
});

function agents() {
  return loadCustomAgents(import.meta.dirname, false, { packageDirs: [], packageFiles: [] });
}
