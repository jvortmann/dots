# GLOSSARY.md format

```md
# {Context name}

{One or two sentences: what this context is and why it exists.}

## Language

**Order**:
{One or two sentences that say what the term is.}
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment for an **Order**, sent to its **Customer** after delivery.
_Avoid_: Bill, payment request

**Customer**:
A person or organization that places an **Order**.
_Avoid_: Client, buyer, account
```

## Rules

- **Pick one word.** When several words name one concept, choose the best and
  list the others under `_Avoid_`.
- **Keep each definition short.** One or two sentences. Say what the thing is,
  not what it does.
- **Bold another term in a definition.** Write `**Order**`, and let the
  sentence say how the two relate.
- **List only terms of this context.** A general programming idea, such as a
  timeout or an error type, does not belong, even when the project uses it
  often.
- **Group terms under subheadings** when clusters form. A flat list is fine
  for one cohesive area.

## Map of contexts

A repo with many contexts has a `GLOSSARY-MAP.md` at the root. It lists each
context with its path, then how the contexts relate:

```md
# Glossary map

## Contexts

- [Ordering](./src/ordering/GLOSSARY.md): receives and tracks customer orders
- [Billing](./src/billing/GLOSSARY.md): makes invoices and takes payments

## Relationships

- **Ordering → Billing**: Ordering emits `OrderPlaced`, and Billing makes the
  invoice from it
```
