---
name: search-and-cite
description: Preloaded by the Explore and research agents. It carries how to search code and documents, how to keep bash read-only, and how to cite each claim in the answer.
disable-model-invocation: true
---

# Search and cite

## Bash reads only

Bash is for reading only: `ls`, `git status`, `git log`, `git diff` and
commands like them. Never write to a file with a redirect (`>`, `>>`), a pipe
into a file, `tee` or a heredoc. Never run a command that changes state.

Never run a command that asks for a password or admin rights, such as
`sudo` or `sfltool`. Name it in the report with what it would show, and the
main session asks the user.

## The search

- Use the `find` tool to match file patterns, and not `find` in bash.
- Use the `grep` tool to search content, and not `grep` or `rg` in bash.
- Use the `read` tool to read a file, and not `cat`, `head` or `tail` in bash.
- Make independent tool calls in parallel.
- Search the repository and the folders that your prompt names. Never
  search from `~`, `$HOME` or `/`, with a tool or in bash. Never list or
  read `~/Pictures`, `~/.Trash`, `~/Library/CloudStorage`,
  `~/Library/Mobile Documents` or `~/Library/Containers`. macOS shows the
  user a privacy prompt for each. Read a file there only at the exact path
  that your prompt gives. When a file is not where your prompt
  says, report it as not found.
- Match the depth of the search to the thoroughness the caller asks for. A
  quick look needs a few calls. A thorough search covers every place the
  answer can live.
- No person can answer an ask in a subagent, so the policy blocks it. When a
  deny or an ask blocks a path or a command, stop the search that needs
  it. Name the path or the command in your answer. Never do the same work
  another way, such as `cat`, `python3` or a heredoc in bash.

## Shell commands

- Never start a bash command with `cd`. Each command already runs in the
  working directory. Give an absolute path, or put the `cd` and one command
  in a subshell: `(cd dir && cmd)`. Take the path from your prompt, and
  never from memory. When you are not sure where you are, run `pwd`.
- Keep a command that the permission policy can block out of a compound
  command with `;`, `&&` or `|`. The policy checks the whole command line,
  so one blocked part stops every part. When you are not sure that the
  policy allows a command, run it in a call of its own.

## The answer

- Use absolute paths in every reference.
- Back every claim with its source: an absolute path with a line number,
  or a URL. Mark a claim that has no source as not verified, and do not
  state it as a fact.
- Report your findings as a plain message.
- Use no emojis.
- Be thorough and precise.
