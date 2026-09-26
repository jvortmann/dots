---
name: pi-sessions
description: Load whenever a past pi session needs reading or measuring, every time. That covers what an agent or a subagent did, a review of a session, a retrospective, a count of tool calls or costs, and a question such as which skill an agent loaded. It carries where sessions live, how to find one, and the DuckDB scripts and queries that read them.
---

# Pi sessions

pi stores each session as a JSONL stream, one JSON event per line. Read them
with DuckDB, through the scripts and queries beside this file. Resolve every
path relative to this skill directory.

## Where they live

Sessions sit in `$PI_CODING_AGENT_DIR/sessions/`, or `~/.pi/agent/sessions/`
when that variable is unset. Each project gets one folder, named from its path
with `/` turned to `-`, such as `--Users-alice-prj-app--`. A file name starts
with its UTC start time and ends with the session id.

- **A subagent writes its own session** in the same project folder as its
  parent. Find it by its first user message, which is the prompt it got.
- **The parent session also holds that prompt**, so a text search matches both.
  Leave the parent out by its id before you trust a match.
- **The history can run to tens of GB.** One scan of all of it took every
  core and filled the disk with temporary files. Read one project folder at a
  time. The views refuse to build without `PI_SESSIONS_GLOB`, and they cap
  DuckDB at four threads and 4 GB of memory.

## Read one session

Use this when the question is what happened in a session.

1. Choose one file. Match the project, the time, the id, or the first prompt.
2. Profile it. Count events by role and content type before you read payloads.
   The query is in `references/queries.md`.
3. Extract the conversation text, and read all of it before you summarize:

   ```sh
   bash ./scripts/conversation-text.sh /absolute/path/session.jsonl
   ```

4. Query tool calls, tool results or thinking only when the question needs them.

To see which skills an agent loaded, find each `read` tool call whose path ends
in a `SKILL.md`, and keep their sequence. Such a read is the proof a skill
fired.

## Measure many sessions

Use this for counts, trends, costs and comparisons.

```sh
PI_SESSIONS_GLOB="$PI_CODING_AGENT_DIR/sessions/--Users-alice-prj-app--/*.jsonl" \
  duckdb -bail sessions.duckdb < ./scripts/create_views.sql
```

It builds `pi_events`, `pi_messages`, `pi_conversation` and `pi_tool_calls`.
Keep `-bail`, so the refusal stops the script. Keep the glob set when you
query, because a view reads the files again each time.
Take a query from `references/queries.md`, and narrow by session, project or
time as early as you can.

## Traps in the data

- Message fields sit under a `message` struct: `message.role`,
  `message.content`. A bare `role` or `content` does not exist.
- `content` is a list of items in most messages, but a plain string in the
  `system` messages a subagent receives. Mixed in one file, DuckDB types it as
  JSON. Unnest it as `JSON[]`, keep only arrays, and read an item with
  `(item->>'type')`. The parentheses matter, because `->>` binds more loosely
  than `=`. The bundled scripts and queries already do this.
- `~` does not expand in SQL. Use an absolute path or `getenv('HOME')`.
- Read the JSONL with `format='newline_delimited'` and `ignore_errors=true`.

The full event schema is in `references/schema.md`.
