# Design it twice

Use this when the user wants alternative interfaces for a module chosen for
deepening. It follows "Design It Twice" by Ousterhout: the first idea is
rarely the best. The words are those of `SKILL.md`: module, interface, seam,
adapter, `leverage`.

## 1. Frame the problem space

Before you start any subagent, write an explanation for the user:

- The constraints that any new interface must meet.
- The dependencies it would use, and the category of each. See
  `deepening.md`.
- A rough code sketch that makes the constraints concrete. It is not a
  proposal.

Show it to the user, then go straight to step 2. The user reads while the
subagents work in parallel.

## 2. Start the subagents

Start three or more subagents in parallel with the Agent tool. Set
`subagent_type` to `Plan`. Each one must produce a radically different
interface for the deep module.

Give each subagent its own technical brief. It holds file paths, how the
code couples, the dependency category, and what sits behind the seam. It does
not depend on the explanation from step 1. Give each subagent a different
constraint:

- Agent 1: use the smallest interface, with one to three entry points. Get the
  most `leverage` from each entry point.
- Agent 2: be the most flexible. Support many uses and extensions.
- Agent 3: serve the most common caller. Make the default case trivial.
- Agent 4, when a dependency crosses a seam: design around ports and adapters.

Put the vocabulary of `SKILL.md` and the project `GLOSSARY.md` in each brief.
Then each subagent uses the same words for the architecture and the domain.

Each subagent returns:

1. The interface: types, methods, parameters, and also invariants, call order
   and error modes.
2. A usage example that shows how callers use it.
3. What the implementation hides behind the seam.
4. The dependency strategy and the adapters. See `deepening.md`.
5. The trade-offs: where `leverage` is high, and where it is thin.

## 3. Present and compare

Present the designs one after the other, so the user can take in each one.
Then compare them in prose on three points: **depth** (`leverage` at the
interface), **locality** (where change concentrates) and **seam placement**.

End with your own recommendation: the design you think is strongest, and why.
When parts of different designs combine well, propose a hybrid. Be
opinionated. The user wants a clear view, not a menu.
