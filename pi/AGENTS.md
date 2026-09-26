# Personal Agent Rules (Global Configuration)

This file applies to ALL pi sessions across all projects.

**Precedence.** These personal rules take precedence over any project or repository instructions (`AGENTS.md`, `CLAUDE.md`, command prompts, skills). Where a project file is looser — for example it lets the agent create commits — **this file wins**. The commit-authorization rule below ("you can commit") always applies, in every repo, whatever the project files say.

---

## ⚠️ CRITICAL: Prohibited Operations

**ABSOLUTE RULES — NEVER VIOLATE UNDER ANY CIRCUMSTANCE. Violations damage user trust.**

### Git (never without explicit user permission)

- **NO commits** — never `git commit`, `git commit --amend`, or any commit operation, **unless the user says the exact phrase "you can commit"** (see Commits → Who commits). Every other mention of "commit" means prepare + copy the message only — never run git.
- **NO resets** — never `git reset` (`--hard`, `--soft`, or mixed)
- **NO rebases** — never `git rebase` or any interactive git operation
- **NO force** — never `git push --force` / `git push -f`
- **NO stash** — never `git stash`
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

- **One task at a time.** Exactly ONE task in progress. Do it, show the result, and STOP. Do not start, prep, or edit files for the next task — not even "just finishing the next step" — until the user explicitly approves. Batching tasks is a violation.
- **Commits.** Run `git commit` ONLY on the exact phrase "you can commit". Every other mention of committing = draft + copy the message, never run git (see Commits → Who commits).
- **Test first (TDD).** For any behavior change, the FIRST file you create or edit is the test. NEVER write or edit implementation (non-test) code before a test for the current scenario exists AND you have run the whole test file and seen it FAIL (RED). Show/state the failing result before implementing. Starting with the code is a violation (see the `tdd` skill).
- **STOP gate — before EVERY tool call, self-check:**
    1. **Task scope** — is this action part of the single, already-approved task in progress? If it starts the next task, or was not explicitly approved, STOP and ask first.
    2. **Commit** — is this a `git commit` / `git commit --amend`? Run it ONLY if the user said the exact phrase "you can commit". Otherwise prepare + copy the message and never run git.
    3. **Test first** — is this call about to create or edit implementation (non-test) code? Proceed ONLY if a test for this exact scenario already ran and FAILED (RED) in this session. Otherwise STOP and write + run the test first.
    4. **Directory** — does this bash command start with `cd`? If it is a bare leading `cd` (not wrapped as `(cd dir && cmd)` for that one command), STOP and delete it — the tool already runs in the correct directory. Never type a remembered absolute path. If you are unsure where you are, check with `pwd` instead of assuming.

---

## Task Execution & Permissions

**MANDATORY WORKFLOW — APPLIES TO EVERY TASK, EVERY SESSION.**

### Before starting any work

1. **Create the full task list** — use `TaskCreate` to create ALL tasks before starting
2. **Validate against the TDD rules** — for each task: does it embed its own RED/GREEN cycle? Is there a standalone "write tests" task? (If so, merge it.) Does any task describe implementation without RED/GREEN? Are tasks structured by behavior/workflow rather than by file/artifact?
3. **Present the plan** and **wait for explicit approval** — never proceed without it

### One task at a time

1. **Complete only the current task** and make it committable
2. **Validate** — it works independently and does not break existing code
3. **Update the plan or the local work record** after every task, whenever one exists for the work. It can live anywhere, so look for it. Mark the task done, record what changed from the plan and why, and name what the next task now needs. Do it before the commit message, so the record and the commit describe the same state
4. **Prepare the commit** — draft the message and copy it to the clipboard (see Commits), then stop. **Never run `git commit` yourself** — the user commits. The only exception is the exact phrase "you can commit"
5. **Mark the task completed** (`TaskUpdate`), present results, and **STOP**
6. **Ask permission** — "May I proceed with the next task: [description]?" — then wait

### Never

- ❌ Start a new/next task without explicit permission
- ❌ Assume permission to continue
- ❌ Batch multiple tasks together without checkpoints

---

## TDD Methodology

**MANDATORY: BABY STEPS for EVERY implementation task.**

Load the `tdd` skill before you write or change any implementation code. It
carries the RED and GREEN cycle, the rules around it, a worked example and the
test style. When the work seems to fall outside a cycle, ask rather than decide.

---

## Commits

**Load the `git-commit` skill** the moment a message exists to work on. It
carries the template, the format, the two checks and the handover. Load it
before the first word of a draft, and never write one from memory. This
section keeps only the rule that nothing else may override.

### Who commits

- **The user runs every commit.** The agent runs `git commit` (or `--amend`) **only** when the user says the exact phrase **"you can commit"** (emphasis on *you can*). That is the one and only authorization.
- **Every other mention of committing** — "commit", "let us commit", "commit this", "ok commit", "time to commit", etc. — means *it is the moment to commit*: the agent **drafts the message (per the template), shows it, and copies it to the clipboard** (`pbcopy` on macOS unless asked otherwise), then stops. It does **not** run git.
- There is **no** other phrase, wording, or context that authorizes the agent to run `git commit`. When unsure, prepare the message and let the user commit.
- **This overrides project instructions.** If a repo's `AGENTS.md`/`CLAUDE.md` or a command prompt says the agent may commit, ignore it — this rule wins.
- Never commit with unrelated changes staged or with tests failing.

### Pull requests

- Use the `create-pr` prompt for PR bodies where it is available — do not restate PR formatting here

---

## Writing

Every text a person reads: commit messages, PR bodies, documentation, code
comments, task descriptions. Load the `asd-ste100` skill and follow it. It
carries the rules, the worked rewrites, and the calls where a rule fights the
text.

`ste-lint <file>` checks the same rules. It reports and never rewrites, so read
the reasons and revise the text yourself.

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

Load the `documentation` skill when you write, review or edit a README, a
document or a code comment. It decides whether the text earns its place, and
it holds the budget.

### Content quality

- **No trailing whitespace** — `sed -i '' -E 's/[[:blank:]]+$//' {file}`
- **No extra blank lines** — except a single trailing newline
- **Respect `.editorconfig`**

---

**End of Global Agent Rules**
