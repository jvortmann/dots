---
name: domain-modeling
description: "Load whenever the domain language or a lasting decision is at stake, every time. That covers a term that is new, vague, overloaded or in conflict with the glossary, a claim of the user about how the domain works, and a decision that may need an ADR. Any write to a GLOSSARY.md or to docs/adr counts too. Only reading those files needs no skill. It carries how to challenge a term, how to check a claim against the code, the test for an ADR, and the formats of both files."
---

# Domain modeling

Build the domain model while you design. Challenge terms, test them on edge
cases, and write each resolved term or decision down at once. Reading
`GLOSSARY.md` for its words needs no skill. Load this one when you change the
model.

## Where the files live

- One context, which is most repos: `GLOSSARY.md` at the root and ADRs in
  `docs/adr/`.
- Many contexts: a `GLOSSARY-MAP.md` at the root lists them. Each context has
  its own `GLOSSARY.md` and `docs/adr/`. The root `docs/adr/` holds the
  decisions for the whole system. Find the context of the topic. When it is
  unclear, ask the user.
- Create each file only when its first entry exists. Make `GLOSSARY.md` with
  the first settled term, and `docs/adr/` with the first ADR.

## During the design

- **Challenge a term against the glossary.** When the user means something
  else than the entry says, say so at once and ask which is right.
- **Sharpen vague words.** For an overloaded word such as "account", propose
  one precise term for each meaning.
- **Test with a concrete case.** Invent an edge case that forces a sharp line
  between two concepts.
- **Check what the user claims against the code.** When the code disagrees,
  show the contradiction and ask which one is right.
- **Write the term as soon as the user settles it.** Do not collect terms for later.

## Write the entry

Follow `GLOSSARY-FORMAT.md` for a term and `ADR-FORMAT.md` for an ADR. Read
the one you need before you write.

The entries are text that a person reads. Hand each one to the `editor`
agent, so it follows the `asd-ste100` skill and passes `ste-lint`. When you
are the editor, write it yourself and check it.

`GLOSSARY.md` holds no implementation detail. It is not a spec, a scratch
pad or a place for decisions. A decision goes in an ADR, and a plan goes in
the plan.

## Offer an ADR sparingly

Offer an ADR only when all three are true:

1. **Hard to reverse.** Changing your mind later costs a lot.
2. **Surprising without its context.** A later reader will ask why the code
   is this way.
3. **A real trade-off.** There were true alternatives, and you chose one for
   a stated reason.

When one is missing, write no ADR. Ask the user with `ask_user_question`
before you write it. Do not reopen an existing ADR without a strong reason.
