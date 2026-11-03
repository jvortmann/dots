---
description: Define what to build at the product level, before any plan (read-only)
argument-hint: "<what you want>"
---

Define what to build and why, at the product level. Name no implementation step. A later run checks the work against the "Done when" list.

Request from the user: "$@"

## 1. Read only

- Change no file. Run nothing that changes state. Write no code. Plan no implementation.
- When the request above is empty, ask the user what they want with the `ask_user_question` tool, and wait.
- Keep the request in the words of the user.
- When the request touches code, start an `Explore` agent. Ask it for the current behavior, the words the code and `GLOSSARY.md` use, and the ADRs in `docs/adr/` that bound the request. Those decisions stay closed unless the request needs them open.

## 2. Close the gaps

Find each gap that changes the goal: an unclear actor, a scope that could go two ways, a missing limit. Ask about each one with the `ask_user_question` tool.

- Do not ask what the code or the request already answers.
- Put your suggested answer first. Give each option its tradeoff in its description.
- Ask the questions in one call when they do not depend on each other.

## 3. Write the goal

Use exactly these five sections, in this order:

- **What:** the thing to build, described as a thing. Give no steps to build it.
- **Why:** the problem it solves, and what is wrong with the current state.
- **End state:** how the system looks and behaves when the work ends. Be concrete, from the side of a user or a caller.
- **Non-goals:** what is explicitly out of scope.
- **Done when:** a checklist of observable criteria. A person or a test can check each one: an output, a state or a behavior. Never use a feeling or a wish about code quality.

Use the domain words of the project. Give no file path, no code, no module name and no step. They go stale, and they belong to the plan.

## 4. Show and save

Show the goal in the reply. Then offer to save it as a markdown file where the repository keeps its plans. The `plan` skill says where that place is. Write the file only when the user says yes.

## 5. Offer the plan

Offer to turn the goal into a plan with the `plan` skill. The "Done when" list becomes the proof that the plan must reach. Write no plan until the user agrees.

Adapted in part from `to-spec` by Matt Pocock (MIT).
