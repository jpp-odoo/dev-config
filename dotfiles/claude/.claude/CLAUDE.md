# User Preferences

## Code style

- **KISS** — Keep It Simple, Stupid. Always prefer the simplest correct solution.
  Never over-complicate with new abstractions, groups, services, or infrastructure
  when a direct call or a one-liner achieves the same thing. Fewer files, fewer
  moving parts, simplest first.

## Sessions

- When a task is done, or I say I'm switching, closing or "wrap up": save what a future
  session needs (new rules I gave, decisions, unfinished work and where we stopped) to the
  project's memory, or to its CLAUDE.md for rules that belong to the project. Then tell me in
  one line what you saved, so I can close the session without losing anything.

## Git

- **Never push** any branch unless I explicitly ask you to in that conversation.
- **Never add Co-Authored-By** lines (or any Claude/Anthropic attribution) to commit messages.

## Odoo goo workspaces: do it yourself (global memory)

- Never ask me to install modules, start a server or give a URL. Find and do it yourself with docker/goo.
- The workspace server is goo's container `dev` (network `goo_odoo`, port 8069). IP:
  `docker inspect dev --format '{{.NetworkSettings.Networks.goo_odoo.IPAddress}}'`. DB = workspace dir name,
  login admin/admin. SQL: `docker exec goo-postgres psql -U odoo -d <db>`.
  Install extra modules with the odoo-test skill's throwaway container (`-i <module>`), not in `dev`.
- Screenshots (I need them regularly): use `deno run -A ~/.claude/tools/odoo-shot.mjs <outdir> '<json [{name,path,js?,wait?}]>'`
  with env `ODOO_DB=<db>`. Header of the script lists the options (per-shot cids, file upload). Deep link: `/odoo/action-<xmlid>`.
  Host has no npm/playwright/pip libs: only chromium + deno (`npm:puppeteer-core`). Gotchas already solved in the script:
  plain-http needs `--unsafely-treat-insecure-origin-as-secure`, login by JSON-RPC `/web/session/authenticate`
  (login form POST gives a 500), never wait for `networkidle`, `--dev all` first load is slow.
