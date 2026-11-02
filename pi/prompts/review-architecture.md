---
description: Find deepening opportunities in a codebase, show them as an HTML report, then walk the chosen one
argument-hint: "[area]"
---

Find where the architecture causes friction. Propose refactors that turn shallow modules into deep ones. The goal is code that is easy to test and easy for an agent to navigate.

Area named by the user: "$@"

## 1. Vocabulary

Load the `codebase-design` skill. Use its words exactly: module, interface, implementation, depth, seam, adapter, `leverage`, locality. Never replace them with component, service, API or boundary.

## 2. Scope

- When the area above is not empty, look there and skip the rest of this step.
- Otherwise, read `git log --oneline` over a good stretch of history. Find the files that keep changing. Look at those first. When the changes are spread out with no clear hot spot, widen the search.
- Read `GLOSSARY.md` and the ADRs in `docs/adr/` for that area, when they exist. The glossary names the domain. The ADRs hold decisions you must not reopen without cause.

## 3. Explore

Start an `Explore` agent with a fresh context. Ask it to walk the code and note friction:

- One concept that needs many small modules to understand.
- Shallow modules, where the interface is almost as complex as the implementation.
- Pure functions pulled out only for tests, while the bugs sit in how the code calls them.
- Modules that leak across their seams.
- Code that is hard to test through its interface.

Apply the deletion test to each suspect. Would deleting the module concentrate the complexity, or only move it? Keep the ones where it concentrates.

## 4. Report

Write one self-contained HTML file to `${TMPDIR:-/tmp}/architecture-review-<timestamp>.html`, so nothing lands in the repository. Run `open <path>`. Give the user the absolute path.

Read `~/.config/pi/skills/codebase-design/references/html-report.md` and follow it. Make one card for each candidate:

- The files involved.
- The problem and the solution.
- The benefits, in terms of locality, `leverage` and tests.
- A before and after diagram.
- A strength badge: Strong, Worth exploring or Speculative.

End with the top recommendation and the reason for it. Use the glossary words for the domain. Show a candidate that contradicts an ADR only when the friction justifies reopening the ADR. Mark it with a warning.

## 5. Choose

Propose no interface yet. Ask which candidate to explore with the `ask_user_question` tool. Put your recommended candidate first.

## 6. Walk the decisions

Load the `explore-design-space` skill for the chosen candidate. Settle these decisions in order:

- The constraints.
- The dependencies, and the category of each.
- The shape of the deeper module.
- What sits behind the seam.
- Which tests survive.

When the user wants alternative interfaces, follow `references/design-it-twice.md` in the `codebase-design` skill.

When a new module name has no term in `GLOSSARY.md`, propose the term. When the user rejects a candidate for a reason that a later review needs, offer to record an ADR. Skip a reason that is short-lived or obvious. Ask before you write either file.
