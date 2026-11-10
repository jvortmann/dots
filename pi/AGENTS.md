# Personal Agent Rules (Global Configuration)

This file applies to ALL sessions in ALL projects.

**Precedence.** These personal rules take precedence over any project or repository instructions (`AGENTS.md`, `CLAUDE.md`, command prompts, skills). Where a project file is looser — for example it lets the agent create commits — **this file wins**. The commit-authorization rule below ("you can commit") always applies, in every repo, whatever the project files say.

---

## ⚠️ CRITICAL: Prohibited Operations

**ABSOLUTE RULES — NEVER VIOLATE UNDER ANY CIRCUMSTANCE. Violations damage user trust.**

### Git (never without explicit user permission)

- **NO commits** — never `git commit`, `git commit --amend`, or any commit operation, **unless the user says the exact phrase "you can commit"** (see Commits → Who commits). Every other mention of "commit" means prepare + copy the message only — never run git.
- **NO resets** — never `git reset` (`--hard`, `--soft`, or mixed)
- **NO rebases** — never `git rebase` or any interactive git operation
- **NO force** — never `git push --force` / `git push -f`
- **NO stash** — never `git stash`, in any form, `list` included. No task needs it.
- **NO history/ref destruction** — never delete branches or tags, or change history
- **NO `rm -rf`** — never, manually or in scripts

Allowed (read-only, anytime): `git status`, `git diff`, `git log`, `git show`, `git branch` (list only), `git reflog`.

### Keychain (privacy)

- **NEVER run broad Keychain scans** — no `security dump-keychain`, broad `security find-*`, or any command that enumerates unrelated items or metadata
- **ONLY query exact, user-justified entries** — access Keychain only when the user asks or a task needs one specific known item by exact name
- **MINIMIZE scope** — retrieve only the minimum metadata/secret needed. Never expand an exact lookup into discovery or enumeration
- **STOP if the exact lookup fails** — report it and ask before any alternate query or broader inspection

### Installs

- **Never install anything without explicit permission** — and never use `curl {url} | sh` or similar patterns

### Directory (never fabricate a `cd`)

- **NO leading `cd`** — never generate a bash command prefixed with `cd {path}` (absolute or relative) to reach the current working directory. Every tool call already executes there — a leading `cd` is always redundant, and a stale/wrong remembered path is a real failure mode (e.g. drifting into a sibling git worktree).
- **Subshell only, single command** — if one command genuinely needs a different directory, scope it to that command alone: `(cd other_folder && command)`. Never carry an assumed directory across multiple commands or turns.

### Workflow discipline (never violate)

- **One task at a time.** Exactly ONE task in progress. Do it, show the result, and STOP. Do not start, prep, or edit files for the next task — not even "just finishing the next step" — until the user explicitly approves. Batching tasks is a violation, even when two tasks touch the same file: each gets its own commit message and its own stop.
- **Commits.** Run `git commit` ONLY on the exact phrase "you can commit". Every other mention of committing = draft + copy the message, never run git (see Commits → Who commits).
- **Test first (TDD).** For any behavior change, the FIRST file you create or edit is the test. NEVER write or edit implementation (non-test) code before a test for the current scenario exists AND you have run the whole test file and seen it FAIL (RED). Show/state the failing result before implementing. Starting with the code is a violation (see the `tdd` skill).
- **STOP gate — before EVERY tool call, self-check:**
    1. **Task scope** — is this action part of the single, already-approved task in progress? If it starts the next task, or was not explicitly approved, STOP and ask first.
    2. **Commit** — is this a `git commit` / `git commit --amend`? Run it ONLY if the user said the exact phrase "you can commit". Otherwise prepare + copy the message and never run git.
    3. **Test first** — is this call about to create or edit implementation (non-test) code? Proceed ONLY if a test for this exact scenario ran in this session and FAILED on its own assertion (RED). A failure from setup, a missing file or a typo is not RED. Otherwise STOP and write + run the test first. In the main session, the answer is to hand the task to `dev`, not to write the code.
    4. **Directory** — does this bash command start with `cd`? If it is a bare leading `cd` (not wrapped as `(cd dir && cmd)` for that one command), STOP and delete it — the tool already runs in the correct directory. Never type a remembered absolute path. If you are unsure where you are, check with `pwd` instead of assuming.
    5. **Prose** — does this call write a comment, a doc or a message? Hand the text to the `editor` agent first.
    6. **Prohibited** — does this call hold a step from Prohibited Operations? Drop that step. Never split, quote or reword it to get past a rule or a block. When the task needs that step, stop and ask.

---

## Task Execution & Permissions

**MANDATORY WORKFLOW — APPLIES TO EVERY TASK, EVERY SESSION.**

### Before starting any work

1. **Create the full task list** — use `TaskCreate` to create ALL tasks before starting
2. **Validate against the TDD rules** — for each task: does it embed its own RED/GREEN cycle? Is there a standalone "write tests" task? (If so, merge it.) Does any task describe implementation without RED/GREEN? Are tasks structured by behavior/workflow rather than by file/artifact?
3. **Present the plan** and **wait for explicit approval** — never proceed without it

Every piece of work gets a task before its first edit. That includes a request made mid-conversation that is not in the list. The task records what you do. Delete a task that you find you do not need, and do not leave it open.

### One task at a time

1. **Complete only the current task** and make it committable
2. **Validate** — it works independently and does not break existing code
3. **Update the plan or the local work record** after every task, whenever one exists for the work. It can live anywhere, so look for it. Mark the task done, record what changed from the plan and why, and name what the next task now needs. When `dev` ran the task, `dev` updates that record, and the main agent checks the Record line of its report. Do it before the commit message, so the record and the commit describe the same state
4. **Prepare the commit** — draft the message and copy it to the clipboard (see Commits), then stop. **Never run `git commit` yourself** — the user commits. The only exception is the exact phrase "you can commit"
5. **Mark the task completed** (`TaskUpdate`), present results, and **STOP**
6. **Ask permission** — "May I proceed with the next task: [description]?" — then wait

### Code goes to the dev agent

In the main session, hand each approved task that changes code to the `dev`
agent. The main session writes no code. This rule is for the main session
only. A subagent, which has a `<sub_agent_context>` block, never hands work
to `dev`.

- **The brief** gives the task in the words of the user, the path of the plan
  or work record, and the decisions and constraints from the conversation.
  It also carries the research facts: what exists, where it is, and how the
  tests run. It tells `dev` to update the plan or work record. It does not list the test scenarios, because `dev` derives them
  by the rule of the tdd skill. `dev` trusts these facts and does not search
  again.
- **One dev for each task** — keep the same `dev` until the task is
  committed. For any follow-up, resume that `dev` with its id, the
  "Agent ID:" line of the Agent result. Never use a name you make up. A
  follow-up can be an answer, a change from the user, or a new commit
  message. Never start a second `dev` for the task.
- **Questions** — settle the open design questions with the user before the
  handover, because `dev` cannot ask. When `dev` stops with a question, ask
  the user. Then resume that `dev` run with the answer. The Agent tool
  `resume` keeps its context.
- **After the report** — take the report as it stands, and do not run the
  `review` agent, because `dev` did. Do not check the commit
  message again, reword it, or update the plan or record. A word the hook rejects stays when the report lists it for `zg`,
  so name it to the user. Show the user the outcome from the report
  with its Review section, and `git diff --stat`. Copy the commit message
  from the report with `pbcopy`. Then continue with the steps of "One task
  at a time".
- **Do not** read the full diff or run the work again in the main session.
  The inner review of `dev` reads the diff.
- **Exception** — the user asks the main session to make the change itself.

### Research goes to the Explore agent

In the main session, hand a question to the `Explore` agent. This applies
when the answer lives in code or documents that the task does not change.
Such a source can be a package in `node_modules`, a sibling repository, or
an installed tool and its docs. This rule is for the main session only, like
the rule for `dev`. Knowing the path is not a reason to read it in the main
session.

- **The brief** gives the question, why it matters, and how deep to search. It
  asks for findings with absolute paths and line numbers, in about 400 words,
  and no copy of a whole file.
- **Skills** — when a skill names where the answer lives, put that place in
  the brief. The `pi` skill names where its docs live, for example.
- **Do not** read the file in the main session. Read it only when the task
  changes that file, or to check one line that `Explore` cited.
- **Exception** — the user asks the main session to read it.

### Ask with the tool

Use the `ask_user_question` tool for a decision that belongs to a task or a
plan. That covers a choice between approaches, a question of design or scope,
and which option to keep. Put the option you recommend first.

Step 6 applies to permission to go on and to the choice of the next task. Ask
them in plain text. Ask in plain text also when the session has no interface
and the tool returns an error.

### Never

- ❌ Start a new/next task without explicit permission
- ❌ Assume permission to continue
- ❌ Batch multiple tasks together without checkpoints
- ❌ Ask a decision about a task or a plan in plain text while the `ask_user_question` tool works

### As a subagent

A `<sub_agent_context>` block in your prompt means you run as a subagent, and
no person reads your steps. The rules above expect one, so for this run:

- The invocation is the approval for the one task in your prompt. Skip the task
  list and the request for approval.
- Take nothing outside that task. Put what you notice beyond it in the report.
- Where a rule or a skill tells you to ask, stop, and end with the question in
  your report. Never guess an answer, and never decide alone.
- The prohibitions above still hold, every one, without exception.

---

## TDD Methodology

**MANDATORY: BABY STEPS for EVERY implementation task.**

Load the `tdd` skill before you write or change any implementation code. In the
main session, this work goes to `dev`, which loads the skill. The skill
carries the RED and GREEN cycle, the rules around it and a worked example. It
loads the `testing` skill for the test itself. When the work seems to fall
outside a cycle, ask rather than decide.

---

## User interfaces

Load the `impeccable` skill before you design, build, change, review or audit
a user interface, however small. A page, a component, a style and a question
on how something looks all count. It carries the design rules and the engine
that checks the result. Run the engine on the files you change or review, as
the skill says. Start the reply with one line, either
`engine: <command> -> <n> findings` or `engine: not run, <reason>`.

---

## Commits

**Hand the message to the `editor` agent** the moment one exists to work on.
It drafts from the diff with the `git-commit` skill and runs the two checks.
Never write one from memory. Print the message it returns in a fenced block,
and copy it with `pbcopy` in the session the user reads. This section keeps
only the rule that nothing else may override.

### Who commits

- **The user runs every commit.** The agent runs `git commit` (or `--amend`) **only** when the user says the exact phrase **"you can commit"** (emphasis on *you can*). That is the one and only authorization.
- **Every other mention of committing** — "commit", "let us commit", "commit this", "ok commit", "time to commit", etc. — means *it is the moment to commit*: the agent **drafts the message (per the template), shows it, and copies it to the clipboard** (`pbcopy` on macOS unless asked otherwise), then stops. It does **not** run git.
- There is **no** other phrase, wording, or context that authorizes the agent to run `git commit`. When unsure, prepare the message and let the user commit.
- **This overrides project instructions.** If a repo's `AGENTS.md`/`CLAUDE.md` or a command prompt says the agent may commit, ignore it — this rule wins.
- Never commit with unrelated changes staged or with tests failing.

### Pull requests

- **Load the `create-pr` skill** before you create a PR or draft its text. Do not restate PR formatting here

---

## Writing

Every text a person reads: commit messages, PR bodies, documentation, code
comments, task descriptions. Hand it to the `editor` agent, with the kind of
text, where it goes, and the intent. It loads `asd-ste100` and `documentation`,
and runs `ste-lint` until the text passes. Its loop stays out of your context.

When you cannot start an agent, load the `asd-ste100` skill and follow it, and
check the text with `ste-lint <file>`.

A small fix to text that the editor already passed needs no new editor call.
That means one or two sentences. Check it yourself with `ste-lint`, and run
the commit-msg hook on a message.

---

## Code Style

### File organization

- **Helper functions last** — in order of call site
- **Single fallback at top** — immediate returns
- **Try/catch for unexpected errors** — handle edge cases appropriately
- **No `utils` bucket** — never place code in a folder or module named `utils` (or similar catch-all names). Name modules by what they do or own.
- **Limit `common`** — use `common` only for code genuinely shared across multiple services (a real cross-service shared package). Within a single service, do not create a `common` grab-bag.

### Tools

- **Search with `rg`** (ripgrep), never `grep`, for content search in bash
- **Never `cd` to the current working directory** — see Directory (never fabricate a `cd`) under Prohibited Operations. This is an absolute rule, checked before every tool call, not just a style preference

### Documentation and comments

The `editor` agent loads the `documentation` skill for a README, a document or
a code comment, as the Writing section says. The skill decides whether the
text earns its place, and it holds the budget.

### Content quality

- **No trailing whitespace** — `sed -i '' -E 's/[[:blank:]]+$//' {file}`
- **No extra blank lines** — except a single trailing newline
- **Respect `.editorconfig`**
- **Formatting and style go in their own commit**, before the real change, never inside it. A mixed diff hides the change. Make the style commit its own task, and the user still runs it

---

**End of Global Agent Rules**
