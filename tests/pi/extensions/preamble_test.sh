#!/bin/bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
EXTENSION="$ROOT/pi/extensions/preamble.ts"

function set_up() {
  [[ -f $EXTENSION ]] || bashunit::fail "missing the file under test: $EXTENSION"
  PI_DIR="$(mise where npm:@earendil-works/pi-coding-agent 2> /dev/null)/lib/node_modules/@earendil-works/pi-coding-agent"
  [[ -f $PI_DIR/dist/core/system-prompt.js ]] || bashunit::skip "needs pi installed with mise"
}

function test_the_prompt_never_names_pi() {
  assert_not_matches '\b[Pp]i\b' "$(prompt_after_the_hook)"
}

function test_the_prompt_opens_with_our_preamble() {
  assert_matches '^You are an expert coding assistant\.' "$(prompt_after_the_hook)"
}

function test_the_prompt_keeps_the_tools_and_the_rules() {
  local prompt
  prompt=$(prompt_after_the_hook)

  assert_contains "<tools>" "$prompt"
  assert_contains "- read: Read files" "$prompt"
  assert_contains "<rules>" "$prompt"
  assert_contains "- Run the suite first" "$prompt"
}

function test_the_prompt_drops_the_docs_section() {
  assert_not_contains "<docs>" "$(prompt_after_the_hook)"
}

function test_the_prompt_drops_the_rule_on_pi_variables() {
  assert_not_contains "PI_" "$(prompt_after_the_hook)"
}

function test_the_prompt_drops_a_reworded_rule_on_pi_variables() {
  local prompt
  prompt=$(run_the_hook "" "" "Read PI_MODEL to learn the model.")

  assert_not_contains "PI_" "$prompt"
  assert_contains "- Run the suite first" "$prompt"
}

function test_the_prompt_keeps_a_rule_on_an_api_key() {
  assert_contains "- Set OPENAI_API_KEY first." "$(run_the_hook "" "" "Set OPENAI_API_KEY first.")"
}

function test_the_prompt_keeps_project_instructions_on_pi_variables() {
  assert_contains "- Set PI_CODING_AGENT_DIR first." "$(run_the_hook "" "" "" "- Set PI_CODING_AGENT_DIR first.")"
}

function test_the_prompt_keeps_the_rules_without_the_bash_tool() {
  local prompt
  prompt=$(run_the_hook "" "read")

  assert_contains "- Run the suite first" "$prompt"
  assert_contains "- Be concise in your responses" "$prompt"
}

function test_the_hook_fails_when_the_preamble_of_pi_changes_its_words() {
  local output
  output=$(run_the_hook "You are an agent that runs in pi, a harness.")

  assert_contains "preamble" "$output"
  assert_contains "not found" "$output"
}

function test_the_hook_leaves_a_custom_prompt_unchanged() {
  local output
  output=$(run_the_hook "# Review")

  assert_matches '^# Review' "$output"
  assert_not_contains "not found" "$output"
}

# The default prompt that pi builds, with the read and bash tools and one
# extension rule, run through the before_agent_start handler of the extension.
prompt_after_the_hook() {
  run_the_hook ""
}

# $1 replaces the preamble sentence of pi before the hook runs, when set.
# $2 is the comma-separated list of tools, read and bash when not set.
# $3 replaces the rule of the bash tool, when set.
# $4 is the content of one project instructions file, when set.
run_the_hook() {
  PI_DIR="$PI_DIR" EXTENSION="$EXTENSION" OTHER_PREAMBLE="$1" TOOLS="${2:-read,bash}" BASH_RULE="$3" INSTRUCTIONS="$4" mise x node@latest -- node --input-type=module -e '
    const { buildSystemPrompt } = await import(process.env.PI_DIR + "/dist/core/system-prompt.js");
    const { bashToolSystemPromptContribution: bash } = await import(process.env.PI_DIR + "/dist/core/tools/bash.js");
    let prompt = buildSystemPrompt({
      selectedTools: process.env.TOOLS.split(","),
      toolSnippets: { read: "Read files", bash: bash.snippet },
      toolGuidelines: process.env.TOOLS.includes("bash") ? { bash: process.env.BASH_RULE ? [process.env.BASH_RULE] : bash.guidelines } : {},
      promptGuidelines: ["Run the suite first"],
      cwd: "/work",
      contextFiles: process.env.INSTRUCTIONS ? [{ path: "AGENTS.md", content: process.env.INSTRUCTIONS }] : [],
      skills: [],
    });
    if (process.env.OTHER_PREAMBLE) prompt = prompt.replace(/^[^\n]*/, process.env.OTHER_PREAMBLE);
    const handlers = {};
    const extension = (await import(process.env.EXTENSION)).default;
    extension({ on: (name, handler) => { handlers[name] = handler; } });
    try {
      const result = await handlers.before_agent_start({ systemPrompt: prompt, systemPromptOptions: {} }, {});
      process.stdout.write(result.systemPrompt ?? prompt);
    } catch (error) {
      process.stdout.write(String(error.message));
    }
  ' 2>&1 | grep -v '^mise WARN'
}
