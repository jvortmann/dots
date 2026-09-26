---
name: testing
description: Load whenever a test is about to be written, changed or judged, every time. The tdd cycle loads it, and so does a review of tests in a diff. It carries what a good test asserts, where a mock belongs, how to design code that is easy to test, and how to name and assert.
---

# Testing

A test states what the system does, through the interface a caller uses. It
survives every change that keeps that behavior, and it fails on every change
that breaks it.

## Test through the interface

- **Exercise the real code path** through the public interface. A test that
  reads like a specification, such as `user can check out with a valid cart`,
  tells the reader which capability exists.
- **Verify through the interface too.** Read the result back the way a caller
  would, and not from the store behind it.

```typescript
// Not this: it bypasses the interface to check the database
await createUser({ name: "Alice" });
const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);

// This: it reads the user back as a caller would
const user = await createUser({ name: "Alice" });
t.is((await getUser(user.id)).name, "Alice");
```

A test that breaks on a refactor, with no change in behavior, tested the
implementation. Rewrite it against the interface.

## Signs of a test on the implementation

- It mocks a module you own.
- It calls a private function.
- It asserts how many times, or in which order, the code calls something.
- Its name says how the code works, not what it does.

## Mock at the boundary only

Mock what you do not control: an external API, the clock, randomness. For a
database or a file system, prefer a local stand-in over a mock. Never mock a
module or a collaborator of your own. The test then checks your guess about
that module, and not the module.

## Design for a test

- **Accept a dependency, do not create it.** `processOrder(order, gateway)`
  takes a stand-in. A function that builds its own gateway does not.
- **Return a result, do not change state.** `calculateDiscount(cart)` returns
  a value to assert. `applyDiscount(cart)` changes the cart, and the test must
  inspect it.
- **Keep the interface small.** Fewer functions and fewer parameters mean
  fewer tests and a simpler setup.

## Name and assert

- **Describe the behavior, not the function.** A test name that carries a
  function name describes the implementation, and it goes stale with it.
  - Write `accepts valid ISO 8601 timestamp strings`
  - Not `validateTimestamp returns valid for ISO strings`
- **Assert true or false, never truthy or falsy.** A truthy check passes on a
  value you did not intend.
  - Write `t.true(typeof result.error === "string" && result.error.length > 0)`
  - Not `t.truthy(result.error)`
- **One behavior for each test.** A test that fails for two reasons leaves the
  reader to find out which one.
