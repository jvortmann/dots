---
name: pi
description: Load whenever a question is about pi itself, every time, before you search its code. That covers settings, keybindings, skills, prompts, sessions, models, themes, extensions, subagents and permissions, and a behavior of pi that needs a cause. It carries where the documentation of pi and of each installed extension lives, and how to read the current session.
---

# Pi

Answer a question about pi from its documentation first. Read its compiled code
only when the documentation does not say, and name the file you read.

## Where the documentation lives

Mise installs pi, so its folder changes with each version. Find it this way:

```sh
P="$(mise where npm:@earendil-works/pi-coding-agent)/lib/node_modules/@earendil-works/pi-coding-agent"
```

- **`$P/README.md`** is the main documentation.
- **`$P/docs/`** holds the rest. `$P/docs/docs.json` is its index, with a title
  for each file, so start there to find the page for a topic.
- **`$P/examples/`** holds working code for extensions, the SDK and RPC. Read
  it before you write an extension.

Resolve `docs/…` and `examples/…` under `$P`, never under the working directory.
Read each page completely, and follow its links to related pages.

The settings, skills, prompts, agents, themes and sessions of this setup live
in `$PI_CODING_AGENT_DIR`, which is `~/.config/pi` here.

## Behavior that comes from an extension

Several features here are not pi core, so its documentation does not cover
them. Read the README of the extension, then its `src/`.

| Feature | Extension | Where |
|---|---|---|
| The Agent tool, agent files, `skills:`, `prompt_mode`, `max_turns` | pi-subagents | `$PI_CODING_AGENT_DIR/npm/node_modules/@tintinweb/pi-subagents/` |
| Tasks, TaskCreate, TaskExecute | pi-tasks | `$PI_CODING_AGENT_DIR/npm/node_modules/@tintinweb/pi-tasks/` |
| Allow, ask and deny rules in `pi-permissions.jsonc` | pi-permission-system | `$PI_CODING_AGENT_DIR/npm/node_modules/pi-permission-system/` |
| MCP servers | pi-mcp-adapter | `$PI_CODING_AGENT_DIR/npm/node_modules/pi-mcp-adapter/` |

An extension installed from git lives under `$PI_CODING_AGENT_DIR/git/`, one
folder for each host, owner and repository.

## The current session

Read the current model, provider, reasoning level and session from these
variables with bash. Never guess them from the prompt: `PI_MODEL`,
`PI_PROVIDER`, `PI_REASONING_LEVEL`, `PI_SESSION_ID`, `PI_SESSION_FILE`. To read
a past session, load the `pi-sessions` skill.
