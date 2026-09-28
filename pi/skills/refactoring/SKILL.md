---
name: refactoring
description: Load whenever code is about to be refactored, cleaned up or restructured, or a change is about to be called a refactor, every time. That covers the refactor step of a tdd cycle, a smell in code under review, and a commit typed refactor. It carries the definition from its source, what it rules out, how to take each small step, and where to find the smells and the catalog.
---

# Refactoring

Most writing online uses the word refactor wrongly, for any rewrite, cleanup
or change that touches a lot of code. You learned the word from that writing,
so your own sense of it is wrong too. Do not trust it. Here the word has one
meaning, the one its source gives:

```text
Refactoring is a disciplined technique for restructuring an existing body of
code, altering its internal structure without changing its external
behavior. Its heart is a series of small behavior preserving
transformations. Each transformation (called a “refactoring”) does little,
but a sequence of these transformations can produce a significant
restructuring. Since each refactoring is small, it's less likely to go
wrong. The system is kept fully working after each refactoring, reducing the
chances that a system can get seriously broken during the restructuring.
```

Martin Fowler, on the home page of refactoring.com.

## What it rules out

- **A change in behavior.** A change that a caller can observe is a feature or
  a fix, even when it also tidies the code. Split the two into separate steps.
- **A refactor on red.** Start only with every test green. A failing test
  hides whether your change kept the behavior.
- **A refactor with no test.** When no test covers the behavior, write one
  first. Without it, nothing proves the behavior held.
- **A rewrite.** Replacing a module in one move is not a refactor, however
  well it ends. A refactor moves in steps that each keep the system working.

## How to refactor

1. Name what is wrong, as a smell from `references/smells.md`.
2. Choose one refactoring for it from `references/catalog.md`, and read its
   page for the mechanics.
3. Make that one move, in the smallest steps its mechanics allow.
4. Run the tests after each step. They stay green, with no test changed. A
   test that must change tested the implementation, so fix that first.
5. Take the next refactoring only when the last one is complete and green.

## In the rest of the work

- **In a tdd cycle**, refactor only after GREEN, and keep the file green.
- **In a plan**, a refactor is its own step, before or after the feature.
- **In a commit**, the type is `refactor`, and the `Refactoring:` trailer
  names the catalog id of each refactoring, such as `extractFunction`. Write
  one line for each.

`references/smells.md` maps 27 smells to the refactorings that remove them.
`references/catalog.md` lists the 66 refactorings of the catalog, with their
ids and their older names.
