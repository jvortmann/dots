---
description: Watch an open pull request until CI ends, then report, find causes and propose fixes
argument-hint: "[pr number, url or branch]"
---

Watch an open pull request in the background until its CI ends. The user keeps working. Then report the state, find the cause of each failure, and propose a fix. Never fix anything yourself.

Pull request from the user: "$@"

## 1. Find the PR

- When the request above is empty, use the PR of the current branch.
- Otherwise it is a number, a URL or a branch name.
- Run `gh pr view <pr> --json number,url,state,headRefName`.
- When there is no open PR, stop and say so in one line.

## 2. Start the watch

Start one background agent with the Agent tool. Use `subagent_type` Explore and `run_in_background` true. Give it these three paragraphs as its prompt, with the PR number filled in:

> Run `gh pr checks <n> --watch --fail-fast --interval 30` with a bash timeout of 1800 seconds. When the time runs out, report the checks that are still pending.

> Then, for each failed check, read the failed log with `gh run view <run-id> --log-failed`. Name the cause: the failing test or step, the error, and the file and line when the log gives them.

> Then read the review state with `gh pr view <n> --json url,reviewDecision,reviewRequests,latestReviews,mergeable,mergeStateStatus`, and read the review comments. Return the facts only. Change no file and run no command that changes state.

## 3. Hand back the turn

Tell the user in one or two lines that the watch runs in the background. Say that the result arrives as a notification. Then end the turn. Do not poll.

## 4. Report

When the notification arrives, read the result of the agent. Reply with:

- This status block, in a fenced block:

```
PR: <url>
CI: <passed | failed | pending> (<n> passed, <n> failed, <n> pending)
Reviewers: <each requested reviewer and their decision, or "none requested">
Merge-ready: <yes | no>, <the reason when no>
```

- Merge-ready is yes only when the review decision reads approved, every check passed, and GitHub reports the PR as mergeable.
- For each failure: the cause with its evidence from the log, and a proposed fix.
- For each review comment that asks for a change: what it asks, and a proposed answer or change.

## 5. Wait

Wait for the user. A fix is a task that the user approves. The user commits and pushes.

Never run `git commit`, `git push`, `git rebase`, `gh pr merge`, `gh pr comment` or `gh pr review`. Never edit a file in this prompt.
