# ADR format

An ADR lives in `docs/adr/` as `NNNN-slug.md`, such as
`0002-postgres-for-write-model.md`. Find the highest number in the folder and
add one.

## Template

```md
# {Short title of the decision}

{One to three sentences: the context, what we decided, and why.}
```

An ADR can be one paragraph. Its value is the record of the decision and the
reason, not a filled-in form.

## Optional parts

Add one only when it earns its place.

- **Status** in the frontmatter: `proposed`, `accepted`, `deprecated` or
  `superseded by ADR-NNNN`. Use it when the team revisits decisions.
- **Considered options**: only when the rejected options are worth keeping.
- **Consequences**: only when a downstream effect is not obvious.

## What qualifies

The three tests are in `SKILL.md`. These kinds of decision usually pass them:

- The shape of the architecture, such as a monorepo or an event-sourced write
  model.
- How contexts talk to each other, such as events in place of synchronous
  calls.
- A technology with lock-in, such as a database, a message bus or an auth
  provider. Not each library, only one that takes a quarter to replace.
- A boundary or a scope. The explicit "no" is as useful as the "yes".
- A deliberate departure from the obvious path, such as manual SQL in place of
  an ORM. It stops the next person from "fixing" it.
- A constraint the code does not show, such as a compliance rule or a partner
  contract.
- A rejected option whose rejection is not obvious.
