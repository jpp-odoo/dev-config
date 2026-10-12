---
name: odoo-upgrade
description: Rules for the Odoo upgrade repositories (odoo/upgrade, odoo/upgrade-util): writing migration scripts (pre-/post-/end- under module/version), upgrade-util helpers, SQL over ORM, SQL formatting, upgrade tests, pre-commit, chore commits, and the upgrade commit message format. Use for any work or commit in an upgrade or upgrade-util repository; for commits there this replaces the odoo-git message format.
---

# Odoo upgrade repositories

The rules come from the odoo/upgrade wiki, which is internal and is not copied into this
repo. Local clone: `~/src/upgrade-wiki` (refresh with `git -C ~/src/upgrade-wiki pull`; if
that fails, use the clone as is and say so).

Read, in `~/src/upgrade-wiki`:

- always: `How-To.md` (script layout, when a script is needed, SQL formatting, branches,
  tests, advice) and `Commit-message.md` (commit format)
- by need: `No-ORM.md` (computed stored fields, bulk work), `Testing.md`,
  `Modules-Management.md`, `pre-commit.md`, `Chore commits.md` (`[chore]` lint-only
  commits), `Upgrade-exceptions.md`, `FAQ.md`

Points that are easy to get wrong:

- The upgrade commit format differs from the odoo/enterprise one (`odoo-git`): tag is
  `[FIX]`/`[ADD]`/`[IMP]`, prefix is `module/version` (brace expansion, `*` for generic),
  and the body links the related odoo/enterprise PRs (`See odoo/odoo#123`).
- Branches are created directly in the upgrade repo (no odoo-dev fork), named like the
  matching odoo-dev/enterprise-dev branch; PRs target master only.
- Scripts use SQL and `odoo.upgrade.util` rather than the ORM, are reentrant, and tolerate
  dirty data.
- Run the pre-commit hook before committing.
