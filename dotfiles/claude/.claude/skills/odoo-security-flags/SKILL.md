---
name: odoo-security-flags
description: Odoo's internal security-review rules (CI flags PY001-PY040, JS001-JS008, XML, CSV, FILE, NGX). Use when writing or reviewing Odoo code that touches eval, open, Markup, SQL, getattr, urljoin, random, crypto, requests, routes/CSRF, bus channels, innerHTML, or when a PR was flagged by the security check, or to write the justification for a flagged line.
---

# Odoo security flags

The rules come from the Odoo enterprise wiki page `Security.md`, which is internal and is
not copied into this repo. Local clone: `~/src/enterprise-wiki` (refresh with
`git -C ~/src/enterprise-wiki pull` when it is more than a few days old; if that fails, use
the clone as is and say so).

1. Read `~/src/enterprise-wiki/Security.md` in full. It supersedes existing codebase practice.
2. For the code at hand, find every construct a rule covers and apply the safe alternative the
   rule gives (e.g. `file_open` over `open`, `Markup` on literals only, `SQL` objects,
   `record[name]` over `getattr`, `request.redirect`, `secrets`/`consteq`).
3. A flagged line needs a justification saying *why it is safe*, not what it is for. "I only
   moved it", "the spec said so" and "I need it to get X" are rejected by the wiki.
4. Combine with `odoo-security` (audit method) and `odoo-guidelines`; this skill is the
   checklist of flagged constructs, those are the review process.
