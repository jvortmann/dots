# Learning record format

A learning record is a file in `learning-records/` named `0001-<slug>.md`.
Find the next number by listing the folder and adding one to the highest.
Make the folder when the first record exists.

A record works like an ADR. It keeps a non-obvious insight that steers later
sessions. You use the records to find the zone of proximal development.

## Template

```md
# {Short title of what the user learned or knows}

{One to three sentences. What the user learned, or knew already, and how it
changes what to teach next.}
```

One paragraph is enough. Add these only when they carry something:

- `Status: superseded by 0007`, in the first line after the title.
- **Evidence**: how the user showed it, such as an answer or a finished task.
- **Implications**: what the record opens or rules out.

## Write a record when

1. The user showed real understanding of something non-trivial. This sets a
   new floor for the next lesson.
2. The user said they already know a topic. Record the depth they claim, so
   no later lesson teaches it again.
3. The user held a wrong belief and now sees why. These records predict
   where related topics will cause trouble.
4. The mission changed because of what the user learned.

## Do not write a record for

- Material that the lesson only covered. Coverage is not learning.
- A term that `GLOSSARY.md` already defines.
- A log of what happened in a session. A record is an insight, not a diary.

## Supersession

When a later record contradicts an earlier one, mark the old record
`Status: superseded by <number>`. Never delete it. The path from the old view
to the new one is useful.
