---
name: odoo-test
description: Run Odoo tests (JS hoot unit tests or Python tests) for an odoo-src workspace, in a throwaway Docker container that reuses Goo's own image, network and Postgres. Use whenever a test needs to be run or a change verified in an Odoo worktree under ~/src/odoo-src. Never run odoo-bin on the host, never ask the user how to run tests.
---

# Run Odoo tests through Goo's Docker setup

Don't ask the user how to run tests, and don't run `./odoo-bin` on the host (no Odoo deps there; never install anything). Everything is in one script:

```
~/.claude/tools/odoo-test.sh <workspace> <db> '<test-tags>' [extra odoo-bin args]
```

It runs a throwaway container (image `noble`, network `goo_odoo`, Postgres `goo-postgres`, workspace mounted at `/src`, `enterprise` added to the addons path when the workspace has it) and prints only the per-suite results and the failures. Use a long Bash timeout (up to 600000 ms).

The DB is usually named after the workspace (`<workspace>`); check with `docker exec goo-postgres psql -U odoo -l`. If the script fails for an environment reason, inspect Goo's live container (`docker inspect dev`) and fix the script rather than improvising a command.

## Test tags

- **Hoot (JS) file or suite.** Run both desktop and mobile, since a test only runs in the suites its `test.tags(...)` allow:
  `/web:WebSuite.test_unit_desktop[@<addon>/<path under static/tests, without .test.js>],/web:MobileWebSuite.test_unit_mobile[@<same>]`
  Example: `@web/webclient/settings_form_view/settings_form_view`. Add `/<test name>` to target one test.
- **Python:** `/<module>`, `/<module>:<TestClass>` or `/<module>:<TestClass>.<test_method>`.
  Python tests need the module installed in the DB: pass `-i <module>` as extra args only if it isn't installed.

## Read the results

- Hoot prints `[HOOT] "<suite>" ended (passed: N / failed: M ...)` per suite, and for each failure `[HOOT] Test "<name>" failed:` followed by the assertion with `Expected`/`Received`.
- To debug, add a temporary `console.warn("DBG", ...)` in the code. It shows up as `WARNING ... browser: DBG ...` in the full log (run the script's `docker run` without the filter). Remove it afterwards.
- Report pass/fail counts per suite faithfully, with the failure details when something fails.
