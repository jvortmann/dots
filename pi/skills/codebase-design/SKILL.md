---
name: codebase-design
description: "Load whenever code is about to be designed, restructured or judged for its structure, every time. That covers a module and its interface, the place for a seam, a change that makes code easier to test or easier for an agent to find its way in, and a refactor into fewer, deeper modules. It carries the shared vocabulary, the principles, and pointers to deepening a cluster of modules and to designing an interface twice."
---

# Codebase design

Build deep modules: much behavior behind a small interface, at a clean seam,
tested through that interface. Callers get `leverage`. Maintainers get locality.

## Vocabulary

Use these words exactly. Do not say "component", "service", "API" or
"boundary" for them.

- **Module** — anything with an interface and an implementation. It has no
  fixed size: a function, a class, a package or a slice through tiers.
  Avoid: unit, component, service.
- **Interface** — everything a caller must know to use the module correctly.
  That is the types, and also the invariants, the call order, the error modes,
  the configuration and the performance. Avoid: API, signature. Both name
  only the type level.
- **Implementation** — the code inside a module. It differs from an adapter.
  A Postgres repository is a small adapter with a large implementation. An
  in-memory fake is a large adapter with a small implementation. Say
  "adapter" when the seam is the topic, and "implementation" in other cases.
- **Depth** — the `leverage` at the interface: how much behavior a caller or a
  test can use for each part of the interface it must learn. A **deep** module
  hides much behavior behind a small interface. A **shallow** module has an
  interface almost as complex as its implementation.
- **Seam** (Michael Feathers) — a place where you can change behavior without
  an edit in that place. It is the location of a module interface. Where to
  put it is a design decision apart from what goes behind it. Avoid:
  boundary.
- **Adapter** — a concrete thing that satisfies an interface at a seam. The
  word names a role, the slot it fills, and not what is inside.
- **`Leverage`** — what callers get from depth. One implementation pays back
  across N call sites and M tests.
- **Locality** — what maintainers get from depth. Change, bugs, knowledge and
  checks stay in one place. One fix serves every caller.

How they relate: a module has one interface. Depth belongs to the module. You measure it against its interface. A seam is where the interface lives. An
adapter sits at a seam and satisfies the interface. Depth gives `leverage` to
callers and locality to maintainers.

## Principles

- **Depth is a property of the interface, not of the implementation.** A deep
  module can have small parts inside that you can mock or swap. They are
  internal seams, private to the implementation and used by its own tests.
  They are not part of the interface.
- **The deletion test.** Imagine you delete the module. If the complexity
  goes away, the module only passed calls through. If the complexity comes
  back in N callers, the module earned its place.
- **The interface is the test surface.** Callers and tests cross the same
  seam. When you want to test past the interface, the module has the wrong
  shape.
- **One adapter is a hypothetical seam. Two adapters are a real seam.** Do not
  add a seam unless something varies across it.

Ask of every interface: can it have fewer methods, simpler parameters, or
more complexity hidden inside?

## Design for a test

Keep the surface small. Fewer methods need fewer tests, and fewer parameters
make a simpler setup.

Accept dependencies. Do not create them.

```
hard to test:  charge(order)           -> makes its own PaymentClient inside
easy to test:  charge(order, client)   -> the test passes a fake client
```

Return results. Do not change state out of sight.

```
hard to test:  applyDiscount(cart)     -> lowers cart.total, returns nothing
easy to test:  discountFor(cart)       -> returns the discount, the caller applies it
```

## Rejected framings

- **Depth as the ratio of implementation lines to interface lines**
  (Ousterhout). It rewards padding in the implementation. Depth here means
  `leverage`.
- **Interface as only the type-level surface**, such as the `interface`
  keyword or the public methods of a class. An interface includes every fact
  a caller must know.
- **Boundary.** The word also names the bounded context of domain-driven
  design. Say seam or interface.

## In this setup

- Tests through the interface agree with the `testing` skill.
- A deepening changes an interface and replaces tests. Load the `refactoring`
  skill before you call it a refactor. A removed or changed test rules that
  label out.
- Use the `explore-design-space` skill to settle an open design decision.
- The `GLOSSARY.md` of a project names its domain. Use those names for the
  things behind the seam.
- The ADRs in `docs/adr/` record decisions. Do not reopen one without a
  strong reason.

## Go deeper

- Read `references/deepening.md` before you deepen a cluster of modules. It
  sorts dependencies into four categories and sets the test strategy for each.
- Read `references/design-it-twice.md` when the user wants alternative
  interfaces for one module.

Adapted from Matt Pocock's codebase-design (MIT). See `NOTICE.md`.
