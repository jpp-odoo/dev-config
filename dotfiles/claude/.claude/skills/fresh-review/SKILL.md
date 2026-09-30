---
name: fresh-review
description: Review the current changes with fresh eyes, in a new subagent that gets no conversation context and no memory. Use when the user says "fresh review", "make a fresh review", "review it in a new session", or "review without the memory".
---

# Fresh review

The point is an unbiased review: the reviewer must not inherit what this session believes, decided or remembers. Do not review the code yourself.

1. Find the target. By default it's the uncommitted diff (`git diff` plus untracked files) of the repo or worktree being worked on. If there is none, use the unpushed commits (`git log @{u}..`, or the branch's own commits). If the user names a commit, branch, PR or path, use that. When it's ambiguous (several worktrees with changes), pick the one this conversation is about.

2. Spawn a single **new** `general-purpose` Agent. Never use `fork`, which would inherit the context. Its prompt must be self-contained and say:
   - the absolute repo path and the exact command that shows the change (e.g. `git -C <path> diff`);
   - the intent of the change in two or three neutral sentences: what it should do, not how good it is, and without the conclusions or doubts from this conversation;
   - **not** to read or rely on any memory (`~/.claude/projects/*/memory/`, `MEMORY.md`) or earlier-session notes, and to judge the code only against the surrounding source;
   - read-only: no edits, no commits, no test runs, no git state changes;
   - to read the framework code the change depends on (callers, base classes, hooks) rather than trusting the diff;
   - to check correctness and edge cases, whether the approach is the simplest idiomatic one for the codebase, consistency of style and naming, and test quality (do they really test the behavior, what's missing);
   - for Odoo code, to apply the house rules from the `odoo-review` skill if it's available;
   - to report findings ranked by severity, each with `file:line`, a concrete failure scenario and a suggested fix, with confirmed issues kept separate from speculative ones.

3. Tell the user it's running, then wait for the notification. Don't predict results.

4. Relay the findings faithfully, most severe first. Add your own short take on each one (agree, disagree and why, already covered), but never drop or soften one. Don't apply fixes unless the user asks.
