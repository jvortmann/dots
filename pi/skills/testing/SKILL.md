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
- It asserts how many times, or in which order, the code calls a module you
  own. At the boundary such a check is fine, such as one charge sent to a
  payment gateway.
- Its name says how the code works, not what it does.
- It is tautological. The test computes the expected value again with the
  logic of the code, so it passes by construction and can never disagree
  with the code. The expected value is an independent literal. A probe has a
  related rule in the `reproducible-locally` skill. A probe must not hold
  its answer in the prompt or the fixture.

```typescript
// Not this: the test repeats the sum that the code does
const expected = items.reduce((sum, i) => sum + i.price, 0);
t.is(calculateTotal(items), expected);

// This: a known value from a worked example
t.is(calculateTotal([{ price: 10 }, { price: 5 }]), 15);
```

## Mock at the boundary only

Mock what you do not control: an external API, the clock, randomness. For a
database or a file system, prefer a local stand-in over a mock. Never mock a
module or a collaborator of your own. The test then checks your guess about
that module, and not the module.

Prefer one function for each operation of the boundary over one generic
fetcher. Each function gets a mock of its own that returns one shape. A mock
of a generic fetcher must branch on the endpoint.

```typescript
// Not this: the mock must branch on the endpoint
const api = { fetch: (endpoint, options) => fetch(endpoint, options) };

// This: one function for each operation, each mocked on its own
const api = {
  getUser: (id) => fetch(`/users/${id}`),
  createOrder: (data) => fetch("/orders", { method: "POST", body: JSON.stringify(data) }),
};
```

## Pin the output you parse

Code can parse the output of a program you do not own, such as git, a CLI or
a service. The settings of the user can change that output. Name each setting
and env var that does. Pin each one with a flag or option in the call, and
give each pin a test. Its fixture sets the hostile value and shows the output
stays right.

- For `git log`, `log.showSignature` adds signature lines, and
  `i18n.logOutputEncoding` changes the bytes. The pins are
  `--no-show-signature` and `--encoding=UTF-8`.
- Find the settings in the documentation, such as `man git-log` and
  `man git-config`. Never run `env`, `git config --list` or any command that
  prints the settings of the user. They can hold tokens and personal data.

## Mark low-value tests for removal

A low-value test has one job after the change. It restates a value of config,
or it checks that a removed line stays gone. During the cycle it still earns
its place, because it is the specification and the RED that drives the change.
Write it. At the end of the task, mark it for removal. The user decides
whether to cut it, so never delete it on your own judgment.

A change can need several such checks on settings. Write one table-driven
test over a list of expected key/value pairs. A new setting is one more row,
not one more test.

```typescript
const expected = { background: "dark", number: true };
for (const [key, value] of Object.entries(expected)) {
  t.is(readSetting(key), value, key);
}
```

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
- **A comment in a test goes through the `editor` agent.** The name and the
  body carry the behavior. A comment records only a fact they cannot carry.
