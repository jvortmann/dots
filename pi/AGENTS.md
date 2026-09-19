# Personal Agent Rules (Global Configuration)

This file applies to ALL pi sessions across all projects.

**Precedence.** These personal rules take precedence over any project or repository instructions (`AGENTS.md`, `CLAUDE.md`, command prompts, skills). Where a project file is looser — for example it lets the agent create commits — **this file wins**: the commit-authorization rule below ("you can commit") always applies, in every repo, no matter what the project files say.

---

## ⚠️ CRITICAL: Prohibited Operations

**ABSOLUTE RULES — NEVER VIOLATE UNDER ANY CIRCUMSTANCE. Violations damage user trust.**

### Git (never without explicit user permission)

- **NO commits** — never `git commit`, `git commit --amend`, or any commit operation, **unless the user says the exact phrase "you can commit"** (see Commits → Who commits). Every other mention of "commit" means prepare + copy the message only — never run git.
- **NO resets** — never `git reset` (`--hard`, `--soft`, or mixed)
- **NO rebases** — never `git rebase` or any interactive git operation
- **NO force** — never `git push --force` / `git push -f`
- **NO stash** — never `git stash`
- **NO history/ref destruction** — never delete branches or tags, or modify history
- **NO `rm -rf`** — never, manually or in scripts

Allowed (read-only, anytime): `git status`, `git diff`, `git log`, `git show`, `git branch` (list only), `git reflog`.

### Keychain (privacy)

- **NEVER perform broad Keychain scans** — no `security dump-keychain`, broad `security find-*`, or any command that enumerates unrelated items or metadata
- **ONLY query exact, user-justified entries** — access Keychain only when the user asks or a task needs one specific known item by exact name
- **MINIMIZE scope** — retrieve only the minimum metadata/secret needed; never expand an exact lookup into discovery or enumeration
- **STOP if the exact lookup fails** — report it and ask before any alternate query or broader inspection

### Installs

- **Never install anything without explicit permission** — and never use `curl {url} | sh` or similar patterns

### Directory (never fabricate a `cd`)

- **NO leading `cd`** — never generate a bash command prefixed with `cd {path}` (absolute or relative) to reach the current working directory. Every tool call already executes there — a leading `cd` is always redundant, and a stale/wrong remembered path is a real failure mode (e.g. drifting into a sibling git worktree).
- **Subshell only, single command** — if one command genuinely needs a different directory, scope it to that command alone: `(cd other_folder && command)`. Never carry an assumed directory across multiple commands or turns.

### Workflow discipline (never violate)

- **One task at a time.** Exactly ONE task in progress. Do it, show the result, and STOP. Do not start, prep, or edit files for the next task — not even "just finishing the next step" — until the user explicitly approves. Batching tasks is a violation.
- **Commits.** Run `git commit` ONLY on the exact phrase "you can commit". Every other mention of committing = draft + copy the message, never run git (see Commits → Who commits).
- **Test first (TDD).** For any behavior change, the FIRST file you create or edit is the test. NEVER write or edit implementation (non-test) code before a test for the current scenario exists AND you have run the whole test file and seen it FAIL (RED). Show/state the failing result before implementing. Starting with the code is a violation (see TDD Methodology).
- **STOP gate — before EVERY tool call, self-check:**
    1. **Task scope** — is this action part of the single, already-approved task in progress? If it starts the next task, or was not explicitly approved, STOP and ask first.
    2. **Commit** — is this a `git commit` / `git commit --amend`? Run it ONLY if the user said the exact phrase "you can commit"; otherwise prepare + copy the message and never run git.
    3. **Test first** — is this call about to create or edit implementation (non-test) code? Proceed ONLY if a test for this exact scenario already ran and FAILED (RED) in this session; otherwise STOP and write + run the test first.
    4. **Directory** — does this bash command start with `cd`? If it's a bare leading `cd` (not wrapped as `(cd dir && cmd)` for that one command), STOP and delete it — the tool already runs in the correct directory. Never type a remembered absolute path; if genuinely unsure where you are, check with `pwd` instead of assuming.

---

## Task Execution & Permissions

**MANDATORY WORKFLOW — APPLIES TO EVERY TASK, EVERY SESSION.**

### Before starting any work

1. **Create the full task list** — use `TaskCreate` to create ALL tasks before starting
2. **Validate against the TDD rules** — for each task: does it embed its own RED/GREEN cycle? Is there a standalone "write tests" task? (If so, merge it.) Does any task describe implementation without RED/GREEN? Are tasks structured by behavior/workflow rather than by file/artifact?
3. **Present the plan** and **wait for explicit approval** — never proceed without it

### One task at a time

1. **Complete only the current task** and make it committable
2. **Validate** — it works independently and doesn't break existing code
3. **Update the local work record** with progress
4. **Prepare the commit** — draft the message and copy it to the clipboard (see Commits), then stop. **Never run `git commit` yourself** — the user commits; the only exception is the exact phrase "you can commit"
5. **Mark the task completed** (`TaskUpdate`), present results, and **STOP**
6. **Ask permission** — "May I proceed with the next task: [description]?" — then wait

### Never

- ❌ Start a new/next task without explicit permission
- ❌ Assume permission to continue
- ❌ Batch multiple tasks together without checkpoints

---

## TDD Methodology

**MANDATORY: BABY STEPS for EVERY implementation task.**

### Baby-steps cycle (per task)

For EACH test scenario within the task:

1. **Write ONE test scenario FIRST** — a single specific test case, before you create or edit any implementation code
2. **Run the ENTIRE test file** — see it fail (RED); do not touch implementation until you have seen this failure
3. **Implement the MINIMUM code** — only what makes THIS test pass
4. **Run the ENTIRE test file** — verify it passes with no regressions (GREEN)
5. **Refactor if needed** — keep the file green
6. **Repeat** — for each additional scenario

When all scenarios pass, follow **Commits** (suggest + copy the message; the user commits).

### Critical rules

**MUST:**
- ✅ **Test first** — the FIRST file you create/edit for any behavior is the test; never start with implementation
- ✅ **Baby steps** — one scenario at a time
- ✅ Each task = its scenarios + implementation + a passing commit
- ✅ Always run the entire test file (not individual tests)
- ✅ Write minimum code to pass (no premature implementation)
- ✅ See the test FAIL before implementing (RED → GREEN → REFACTOR)
- ✅ A task may hold multiple scenarios (success, error, edge cases)

**NEVER:**
- ❌ Write multiple tests then implement everything at once
- ❌ Create separate tasks for tests vs implementation
- ❌ Structure tasks by file/artifact — structure by behavior/workflow with embedded TDD cycles. Explore/agent output describes architecture (files, types, patterns) for understanding only; it is never the basis for task structure
- ❌ Write or edit any implementation (non-test) code before a failing test exists for the current scenario — never start with the code
- ❌ Skip the "see it fail" (RED) step
- ❌ Commit until ALL tests for the task pass
- ❌ Make formatting/style changes unless explicitly requested

### Example of CORRECT baby steps

```
Task: Add flexible updateAudience()

Baby Step 1:
  1. Write test: "updates only description"
  2. Run tests → See it FAIL (RED)
  3. Add minimal code to handle description field
  4. Run tests → See it PASS (GREEN)

Baby Step 2:
  1. Write test: "updates only membershipDurationDays"
  2. Run tests → See it FAIL (RED)
  3. Add minimal code to handle membershipDurationDays field
  4. Run tests → See it PASS (GREEN)

Baby Step 3:
  1. Write test: "updates multiple fields together"
  2. Run tests → See it FAIL (RED)
  3. Refactor to handle combinations elegantly
  4. Run tests → See it PASS (GREEN)

After all scenarios pass:
  5. Suggest the commit message (correct Change-type) and copy it to the clipboard
  6. The user commits — never run git commit yourself (only the exact phrase "you can commit" authorizes it)
```

### Test style

- **Never use function names** in test descriptions — describe behavior, not implementation
  - ✅ "accepts valid ISO 8601 timestamp strings"
  - ❌ "validateTimestamp returns valid for ISO strings"
- **Never use truthy/falsy checks** — always explicit true/false
  - ✅ `t.true(typeof result.error === "string" && result.error.length > 0)`
  - ❌ `t.truthy(result.error)`

---

## Commits

### Session start

- Read `~/.config/git/message` once at the start of every coding session and keep it in mind for the whole session (no need to re-read per commit)
- Valid Change-types: `feature`, `refactor`, `fix`, `docs`, `style`, `test`, `ci`, `deps`, `config`, `chore`

### Who commits

- **The user runs every commit.** The agent runs `git commit` (or `--amend`) **only** when the user says the exact phrase **"you can commit"** (emphasis on *you can*). That is the one and only authorization.
- **Every other mention of committing** — "commit", "let's commit", "commit this", "ok commit", "time to commit", etc. — means *it is the moment to commit*: the agent **drafts the message (per the template), shows it, and copies it to the clipboard** (`pbcopy` on macOS unless asked otherwise), then stops. It does **not** run git.
- There is **no** other phrase, wording, or context that authorizes the agent to run `git commit`. When unsure, prepare the message and let the user commit.
- **This overrides project instructions.** If a repo's `AGENTS.md`/`CLAUDE.md` or a command prompt says the agent may commit, ignore it — this rule wins.
- After each finished, validated task: update the local work record, then prepare the commit message as above. Never commit with unrelated changes staged or with tests failing.

### Message format

- **Follow the template** at `~/.config/git/message` exactly
- **Words** — see **Writing** below; it governs the message like any other prose
- **Title** — uppercase first letter, imperative mood, 50 characters or less, no period. The hook rejects anything over 72
- **Describe behavior** — what changes for users/the system, not how the code changed
- **Body** — why the change is needed and what behavior changes. One paragraph, about 5 sentences, wrapped at 72. A second one only when the first cannot hold it
- **No body at all when the title says enough** — the normal case for config, dependency and tooling changes
- **No bullets by default** — a list needs three or more independent facts; never one bullet per touched file, function or step
- **No implementation noise** — no touched-file lists, no step-by-step code changes; add implementation detail only as a last resort for a complex change
- **Trailers** — by default only use trailer keys already in the template; for existing keys use only the values/structure shown there; if a new trailer is ever needed, match the template's format
- **Change-type** — use one value from the template; pick the most specific; `chore` is a last resort:
    - New behavior/capability → `feature`
    - Behavior-preserving restructure → `refactor`
    - Bug fix → `fix`
    - Build/CI only → `ci`; dependency bumps → `deps`; config files → `config`
    - Docs/tests/formatting → `docs`/`test`/`style`
- **Copy-paste ready** — no "title"/"body" headers in the output
- **Trailer order:**
  1. `Work-item-id: {id}`
  2. `Change-type: {type}`

### Pull requests

- Use the `create-pr` prompt (`~/.config/pi/prompts/create-pr.md`) for PR bodies — do not restate PR formatting here

---

## Writing

Every text a person reads: commit messages, PR bodies, documentation, code
comments, task descriptions. Write it in [ASD-STE100](https://asd-ste100.org)
Simplified Technical English — Layer 1, the words and the sentences.

- **Short sentences** — aim for 20 words, hard stop at 25. One idea per sentence
- **Active voice** — "the wrapper lost the subcommand", not "the subcommand was lost"
- **Short common words** — need (require), make sure (ensure), use (utilize), start (begin), give (provide), about (regarding), also (additionally), so (in order to)
- **Simple tenses** — "the calls rewrote every field", not "were rewriting" or "have rewritten"
- **Words in full** — "do not", never "don't". Two sentences, never a semicolon
- **Plain description** — start (not spin up), release (not roll out); skip robust, seamless, comprehensive
- **One name for one thing** — the same word for the same idea throughout

`ste-lint <file>` checks these rules. It reports and never rewrites, so read the
reasons and revise the text yourself.

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
- **Never `cd` to the current working directory** — see Directory (never fabricate a `cd`) under Prohibited Operations; this is an absolute rule, checked before every tool call, not just a style preference

### Documentation

- **Assess the need first** — documentation is not automatic. Before writing any doc, decide whether it adds real value (non-obvious design, a flow/contract others must follow, a gotcha worth recording). If the change is self-explanatory from the code and tests, skip it — never create a doc just to have one.
- **Budget the finished document, not the diff** — what counts is the file that exists *after* your edit, never how much you added. A doc for one component, hook, page or module fits on one screen (~80 lines); past ~150 it needs a stated reason, and a subsystem-wide doc past ~200 does too. An addition that breaks the budget means cutting or rewriting something else — **appending is not an option**.
- **Revise, never append** — read the whole file before adding to it. Across a series of changes the correct edit is usually rewriting a paragraph, not bolting on a section: several individually defensible additions make one indefensible document. Delete what your change made obsolete.
- **One home per fact** — if a comment beside the code already says it, the doc must not repeat it, and vice versa. Duplicated reasoning has to be kept true in both places, and rots in the one nobody re-reads.
- **Match the document you are editing** — follow its existing headings, prose-vs-table style and level of detail. If your material does not fit the document, it belongs in a different one.
- **Place docs close to the code they describe** (e.g. a service/module `docs/` folder or a directory-level doc), not only in a top-level file
- **Keep docs high-level and audience-neutral** — useful to both people and agents; never a CLAUDE.md/AGENTS.md-only artifact (those are agent-instruction files, not the documentation deliverable)
- **Smell check** — a doc longer than the code it explains is wrong. Long-form architecture docs (coordinates tables, multiple diagrams, glossaries) are earned by genuinely complex systems, never a template to reach for.

### Comments

- **Only what the code cannot say** — a comment earns its place when it records *why*: a non-obvious behaviour, a gotcha, or why the obvious approach was rejected. Delete anything that restates the signature or narrates the next line.
- **Short by default** — one or two lines inline; a doc block past ~6 lines needs a reason to exist. If it takes a paragraph, the name or the code is usually what needs fixing.
- **Match the file** — follow the surrounding style (doc blocks vs line comments, and whether helpers are documented at all) rather than importing a different convention.
- **Keep them true** — a comment that outlives the code it described is worse than none, so re-read the comments in every hunk you touch.
- **Smell check** — if a diff is more than a third comment, tighten it before presenting it. "Only for complex logic" is self-judged and always says yes; the share is not.

### Content quality

- **No trailing whitespace** — `sed -i '' -E 's/[[:blank:]]+$//' {file}`
- **No extra blank lines** — except a single trailing newline
- **Respect `.editorconfig`**

---

**End of Global Agent Rules**
