# Odoo work (every workspace under ~/src/odoo-src)

A workspace is `~/src/odoo-src/<ws>/` with `odoo/` and `enterprise/` checkouts. Goo runs the
servers, databases and worktrees: never start, stop or exec into its containers.

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

## Commit messages

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

**Give the real why.** Explain why the change is done, and the technical choice after it. "The PO
team asked for it" is not a why. If the real reason is unknown, ask instead of inventing one.

**Be concrete, not abstract.** Name the real cases, components and dialogs affected, before and
after ("forms shown in a dialog (`FormViewDialog`, `x2many` dialogs) were protected, the sale
configurators had to opt in"), never "some dialogs". Keep the facts the diff does not show, such
as what was covered and what was not.

**Stay on the subject.** Do not say what was left unchanged or still works when it is unrelated
to the problem (it is like writing "the router was left unchanged"), and do not repeat in a
closing paragraph what an earlier one already says.

Structure:

- Title `[TAG] module: short description`, ideally under 50 characters. It must complete "If
  applied, this commit will <title>" ("prevent crash on...", "avoid an extra request..."). Tags: `[FIX]` `[IMP]` `[REF]` `[ADD]` `[REM]` `[PERF]` `[MOV]` `[REV]`
  `[I18N]`. Lowercase module, no trailing period.
- Context paragraph: "Before this commit, ..." in the **past** tense (or "Currently, ..." in the
  present). Never mix the two.
- Fix paragraph: "This commit fixes/adds/removes ..." or "With this commit, ...". Not "Now ...".
- Optional short paragraph for testing, bundling or an architectural note.
- Footer: `task-id N` or `opw-N`, and `Related: odoo/enterprise#N` for the sibling-repo half. If
  the number is unknown, ask for it after the message instead of inventing one.
- No markdown headers, continuous paragraphs, body wrapped at 72 characters.
- Backticks on every identifier: file path, variable, function, event name, class, directive,
  library (`FormViewDialog`, `x2many`, `applySearch()`, `monaco-vim`).
- ASCII punctuation only (see `odoo-guidelines` > comments), no em dash.
- No Co-Authored-By or other attribution line (global `CLAUDE.md`).
