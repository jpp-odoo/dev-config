---
name: tuicr-review
description: Open tuicr, the TUI code review, on the current changes in a new herdr tab, then read the user's comments and fix them. Use when the user says "tuicr", "review my changes", "I want to review", "open the review", or "read my review".
---

# tuicr review

tuicr is interactive, so the user reviews it themselves; Claude opens it and later reads the comments from its saved sessions. Never run `tuicr` in Bash.

## Open

1. List the git repos of the workspace this conversation is about (for Odoo: `odoo/`, `enterprise/` and the others of `~/src/odoo-src/<ws>/` that are checkouts) and keep those with changes (`git -C <repo> status --short`). No changes: say so and stop.
2. Always ask which repos to open (AskUserQuestion, multi-select, one option per repo with changes, with its file count), even when only one has changes.
3. For each chosen repo, open a new **tab** (never a pane, it is too narrow) and run tuicr in it:

   ```
   herdr tab create --cwd <repo> --label "review <repo name>" --focus
   herdr pane run <root_pane.pane_id from the output> tuicr -w --no-update-check
   ```

   Pass `--focus` only for the first repo, `--no-focus` for the others. Without herdr (`herdr pane current` fails), tell the user to run `tuicr -w` in each repo instead.
4. Tell the user the tabs are open, then stop and wait. Don't poll, and don't read the comments before the user says they are done.

## Read and fix

When the user says they are done ("done", "read my review"), for each reviewed repo:

1. `tuicr review list --repo <repo>`: take the session with the latest `updated_at` and a non-zero `comment_count`.
2. `tuicr review comments --session <slug> --repo <repo>`: each comment has a file, a line or range and a type (issue, suggestion, note, praise).
3. Fix the issues and apply the suggestions; notes and praise need no change. A comment that is a question gets an answer, not a change. If a comment is unclear, ask instead of guessing.
4. Report what was changed per comment. The user reopens the same session with `tuicr -w` to check the result: comments and reviewed marks are kept.
