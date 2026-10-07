# Claude Code config

My global [Claude Code](https://claude.com/claude-code) config (`~/.claude/`), tuned for Odoo
development with [goo](https://github.com/ged-odoo/goo) (Odoo servers, databases and worktrees in
Docker). It is a GNU Stow package of [dev-config](../../../README.md): each file here is symlinked
into `~/.claude/`.

Feel free to copy anything. Paths are hardcoded to my machine (`/home/jpp`, `~/src/odoo-src`,
goo's `dev` / `goo-postgres` containers): adapt them to yours.

## Layout

| Path | What |
|------|------|
| [`CLAUDE.md`](CLAUDE.md) | Global rules, loaded in every session |
| [`agents/`](agents) | Subagents: `odoo-explorer`, `odoo-tester`, `odoo-reviewer` |
| [`skills/`](skills) | Skills: `odoo-test`, `fresh-review` |
| [`tools/`](tools) | Scripts used by the skills and rules: `odoo-test.sh`, `odoo-shot.mjs` |
| [`settings.json`](settings.json) | Model, effort, status line, hooks, plugins |
| [`statusline-command.sh`](statusline-command.sh) | Status line script |
| [`themes/omarchy.json`](themes/omarchy.json) | Color theme matching my Omarchy desktop |
| [`../../odoo-src/src/odoo-src/CLAUDE.md`](../../odoo-src/src/odoo-src/CLAUDE.md) | Rules for every Odoo workspace (separate `odoo-src` package) |

## Rules

### Global `CLAUDE.md`

- **KISS**: always the simplest correct solution; no new abstractions, files or infrastructure
  when a direct call does the job.
- **Sessions**: when a task is done or I say "wrap up", Claude saves what a future session needs
  (new rules, decisions, unfinished work) to the project memory or `CLAUDE.md`, and tells me in one
  line what it saved. So I can close a session without losing anything.
- **Git**: never push unless asked in that conversation, never add `Co-Authored-By` lines.
- **Odoo goo workspaces, do it yourself**: Claude never asks me to install a module, start a
  server or give a URL. It finds goo's `dev` container IP, the DB (= workspace name, admin/admin),
  uses `psql` in `goo-postgres`, installs modules in a throwaway container, and takes screenshots
  with `tools/odoo-shot.mjs`.

### `~/src/odoo-src/CLAUDE.md` (every Odoo workspace)

- **Delegate the reading, keep the writing**: most of a session's cost is re-reading its own
  context, so big reads and logs go to subagents. Exploring many files -> `odoo-explorer`,
  running tests -> `odoo-tester`, reviewing a non-trivial change -> `odoo-reviewer`. The code is
  written in the main session (it has the context): no writer agents. Small fixes: no delegation.
- **Commit messages**: Odoo's format (`[TAG] module: description`, "Before this commit, ..." /
  "This commit ...", 72 columns, `task-id` / `opw` footer), and above all: describe the *behavior*
  change and the real *why*, not the diff. Concrete cases, no buzzwords, no em dash, never invent
  a task number.

## Agents

Subagents run in their own context and return only a short report, which keeps the main session
small and cheap. Each one uses the model that fits its job.

| Agent | Model | What it does |
|-------|-------|--------------|
| [`odoo-explorer`](agents/odoo-explorer.md) | sonnet | Read-only search in `odoo/` and `enterprise/`: where something is defined, who calls it, how a pattern is done elsewhere, git log/blame. Returns `file:line` pointers, never file dumps. |
| [`odoo-tester`](agents/odoo-tester.md) | haiku | Runs Hoot (JS) or Python tests with the `odoo-test` skill and reports only the command, pass/fail counts and the essential part of each failure. Never edits anything. |
| [`odoo-reviewer`](agents/odoo-reviewer.md) | opus | Context-free review of an Odoo change against the house rules (preloads the `odoo-review` skill). Reports findings by severity, each with `file:line`, a failure scenario and a fix. |

## Skills

| Skill | What it does |
|-------|--------------|
| [`odoo-test`](skills/odoo-test/SKILL.md) | Runs Odoo tests in a throwaway Docker container that reuses goo's image, network and Postgres, through `tools/odoo-test.sh`. Explains the test tags for a Hoot file/suite (desktop + mobile) or a Python module/class/method, and how to read the results. Claude never runs `odoo-bin` on the host and never asks how to run tests. |
| [`fresh-review`](skills/fresh-review/SKILL.md) | "Make a fresh review": reviews the current diff (or unpushed commits, or a given commit/PR) in a **new** subagent with no conversation context and no memory, so the review isn't biased by what the session already believes. Claude then relays every finding with its own short take. |

I also use the Odoo house-rule skills shipped in the `odoo` repo (`odoo/skills/`: `odoo-guidelines`,
`odoo-web-guidelines`, `odoo-security`, `odoo-review`), symlinked into `~/.claude/skills/`. They
are not part of this repo.

## Tools

| Tool | What it does |
|------|--------------|
| [`odoo-test.sh`](tools/odoo-test.sh) | `odoo-test.sh <workspace> <db> '<test-tags>' [-i <module>]`: runs the tests in a `docker run --rm` container on goo's `goo_odoo` network (enterprise added to the addons path when present) and filters the output down to the suite results and failures. |
| [`odoo-shot.mjs`](tools/odoo-shot.mjs) | `ODOO_DB=<db> deno run -A odoo-shot.mjs <outdir> '[{"name","path","js?","wait?"}]'`: screenshots Odoo pages with headless Chromium (puppeteer-core via Deno, nothing to install). Logs in by JSON-RPC, can run JS before the shot (click a menu...), set companies (`cids`) or upload a file. The header lists all options. |

## Settings

- Model `opus`, effort `high`, fullscreen TUI, `auto` theme.
- Status line: model and context size, % of context used, and 5h / 7d rate-limit usage.
- `SessionStart` hooks for herdr (agent state in my
  terminal multiplexer) and `claudio` (my fish function that records session ids). The herdr hook
  script is generated by `herdr integration install claude`, so it is not tracked.
- Plugin: `frontend-design`.
