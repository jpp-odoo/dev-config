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
