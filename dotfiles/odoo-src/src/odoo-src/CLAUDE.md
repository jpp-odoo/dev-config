# Odoo work (every workspace under ~/src/odoo-src)

A workspace is `~/src/odoo-src/<ws>/` with `odoo/` and `enterprise/` checkouts. Goo runs the
servers, databases and worktrees in Docker containers; use them freely to run Odoo and its tests
(`~/.claude/tools/odoo-test.sh`, see the `odoo-test` skill).

`git fetch` fails in the sandbox (no SSH). Run `odoo-fetch` instead: the host fetches origin for
odoo, enterprise, documentation and upgrade, which updates `origin/*` in every workspace, then
rebase as usual. It takes about a minute. Fetching from `dev` is not possible.

## Delegate the reading, keep the writing

Most of the cost of a session is re-reading its own context, so keep big reads and logs out of it:

- Exploring more than a few files (where is X defined, who calls it, how is it done elsewhere)
  -> `odoo-explorer`.
- Running tests -> `odoo-tester` (it follows the `odoo-test` skill and returns only results).
- Reviewing a non-trivial change before calling it done, or when asked -> `odoo-reviewer`
  (the `fresh-review` skill uses it).
- Write the code yourself, in this session: it has the context. No writer agents.
- A question, a small or one-file fix: just do it, no delegation.

Brief each agent with the absolute workspace path, the goal, the files involved and the
expected answer. Run independent agents in parallel. Their results are leads: verify what
matters before relying on it.

## Review of my changes

When a task is done, offer the `tuicr` skill so I can review the diff line by line. Do not
open it unasked.

## Customizations: last resort

A customization (custom template, JS patch, server-side trick, new framework option) is expensive to
maintain. Add one only when it cannot be done in a standard way (arch attributes, existing options,
framework behavior) AND it is really necessary or important, or when I literally asked for it. A
cosmetic difference, such as the order of buttons, is not worth one: keep what the framework decides
and report the difference instead.

## Code comments: only for tricky logic

Do not add comments to the code unless the part or the logic is really tricky (a browser
limit, a non-obvious ordering, a workaround). Names and structure explain the rest: no
comment per block, no comment restating the next line, no docblock repeating the signature.

## Styles: CSS, not SCSS

SCSS is going to disappear from Odoo (runbot warns "avoid using scss" on new `.scss` files). Prefer
native CSS syntax (custom properties, native nesting, `color-mix()`, etc.) over SCSS features when
writing or editing styles, and write new style files as `.css`. Avoid adding new SCSS
mixins/variables/functions; fall back to SCSS only when CSS cannot express it, and say so.

## Python lint: ruff

After editing Python, run ruff on the touched files with the runbot config
(`ruff check --config <ws>/odoo/ruff.toml <files>`, also for enterprise, which has none of its own).
That config is the rule set Odoo enforces (it ignores some rules and notes advisory ones): never
add `--select`/`--ignore` or other rules. Fix only the errors on lines you changed; the files
already carry unrelated ones. Do not run `--fix` on whole files.
The `upgrade` repo is the exception: it has its own `ruff.toml`, so run `ruff check --no-fix <files>`
from `<ws>/upgrade/` (its config sets `fix = true`).

## JS lint: eslint

After editing JS, run eslint on the touched files, from the `odoo/` or `enterprise/` checkout, with
the config that `addons/web/tooling/_eslintrc.json` defines (the `.eslintrc.json` in a checkout is only a
copy made by `enable.sh`, and may be missing or stale in a worktree). A worktree has no
`node_modules`, so borrow the ones of `~/src/odoo-src/master/odoo`:

```
ESL=~/src/odoo-src/master/odoo
$ESL/node_modules/.bin/eslint --no-eslintrc -c <ws>/odoo/addons/web/tooling/_eslintrc.json \
  --resolve-plugins-relative-to $ESL <files>
```

Same rules as for ruff: fix only the errors on lines you changed, no `--fix` on whole files.

## Commit messages

The `odoo-git` skill gives the format: header, tags, scopes (`*` for many modules), trailers, and
what the bots add (`closes`, `Part-of`, `Related`: never write them). The rules below are my
style on top of it.

Write the whole message yourself, output only the final message (no options). Plain, direct
engineering vocabulary: no "plumbed", "delves", "holistic", "robustly", "showcase" and the like.
The message is often the only thing a reader sees of the change, so be as long as the why needs,
and cut only repetition and diff inventory.

**Describe the behavior change, not the code change.** The diff already shows what was edited.
Say what the user or developer saw go wrong (or the limitation), and what happens differently
now. Add the cause only when the diff cannot show it (a browser limit, an earlier commit, a
design intent), and a short mention of the mechanism only when it helps judge the approach. Never
list the files, functions, getters, events or counters added or removed. `[REF]` and `[REM]` have
no behavior change: describe the structural change and why it is better. Self-check: a paragraph
that stays true after renaming every identifier is behavior; one made only of identifiers is the
diff, cut it.

**Give the real why.** Explain why the change is done, and the technical choice after it. If the
real reason is unknown, ask instead of inventing one.

**Be concrete, not abstract.** Name the real cases, components and dialogs affected, before and
after ("forms shown in a dialog (`FormViewDialog`, `x2many` dialogs) were protected, the sale
configurators had to opt in"), never "some dialogs". Keep the facts the diff does not show, such
as what was covered and what was not.

**Stay on the subject.** Do not say what was left unchanged or still works when it is unrelated
to the problem (it is like writing "the router was left unchanged"), and do not repeat in a
closing paragraph what an earlier one already says.

Structure:

- Title: summary ideally under 50 characters.
- For a fix, a "Steps to reproduce:" list first (open Accounting, click X, ...), when there are
  steps to follow.
- Context paragraph: "Before this commit, ..." in the **past** tense (or "Currently, ..." in the
  present), saying what goes wrong and why. Never mix the two tenses.
- Fix paragraph: "After this commit, ...", "This commit ...", or "With this commit, ...",
  whichever reads best, saying how it behaves now. Not "Now ...".
- Optional short paragraph for testing, bundling or an architectural note.
- Footer: `task-N` or `opw-N`, `Fixes #N` for a GitHub issue. If the number is unknown, ask for it
  after the message instead of inventing one.
- No markdown headers and no list of code changes: paragraphs, except the steps to reproduce.
  Body wrapped at 72 characters.
- Backticks on every identifier: file path, variable, function, event name, class, directive,
  library (`FormViewDialog`, `x2many`, `applySearch()`, `monaco-vim`).
- No Co-Authored-By or other attribution line (global `CLAUDE.md`), and never push.
