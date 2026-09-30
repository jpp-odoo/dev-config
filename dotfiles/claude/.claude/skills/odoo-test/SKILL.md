---
name: odoo-test
description: Run Odoo tests (JS hoot unit tests or Python tests) for an odoo-src workspace, in a throwaway Docker container that reuses Goo's own image, network and Postgres. Use whenever a test needs to be run or a change verified in an Odoo worktree under ~/src/odoo-src. Never use oe.fish, never run odoo-bin on the host, never ask the user how to run tests.
---

# Run Odoo tests through Goo's Docker setup

Hard rules:
- Never use `oe` / `oe.fish`. It starts its own `odoo-nginx`/`odoo-db` stack, which breaks Goo.
- Never run `./odoo-bin` on the host. The host Python has no Odoo deps. Never install anything (pip, venv, packages).
- Never stop, restart or exec into Goo's running workspace container (usually named `dev`). It's the user's live server.
- Don't ask the user how to run tests. Just do it.

## 1. Find the workspace setup

Workspaces live in `~/src/odoo-src/<WS>/{odoo,enterprise}`. The DB is usually named after the workspace. Check with:
```
docker exec goo-postgres psql -U odoo -l
```
Look at Goo's live container to copy its image, mounts and args:
```
docker ps --format '{{.Names}} {{.Image}}'
docker inspect <container> --format '{{.Config.Image}} {{json .Mounts}} {{json .Config.Cmd}} {{.Config.User}}'
```
The defaults below match Goo's setup: image `noble`, network `goo_odoo`, Postgres `goo-postgres`, user `odoo_user`, workspace mounted at `/src`.

## 2. Run

```
WS=<workspace>; DB=<db>
docker run --rm --network goo_odoo --user odoo_user --workdir /src/odoo \
  -v /home/jpp/src/odoo-src/$WS:/src \
  -v /home/jpp/src/goo/addons:/goo-addons:ro \
  -v /home/jpp/src/odoo-src/fileStorage:/home/odoo_user/.local/share/Odoo/filestore \
  noble python3 /src/odoo/odoo-bin --db_host goo-postgres --db_port 5432 -r odoo -w odoo \
  -d $DB --addons-path addons,../enterprise,/goo-addons \
  --dev all --stop-after-init --http-port 8070 \
  --test-tags '<TAGS>' 2>&1 | grep -E -A8 '" ended \(|ERROR.*failed:|FAIL:|ERROR:' | cut -c1-400
```
If the workspace has no `enterprise` checkout, drop `../enterprise` from `--addons-path`. Use a long Bash timeout (up to 600000 ms).

## 3. Test tags

- **Hoot (JS) file or suite.** Run both desktop and mobile, since a test only runs in the suites its `test.tags(...)` allow:
  `/web:WebSuite.test_unit_desktop[@<addon>/<path under static/tests, without .test.js>],/web:MobileWebSuite.test_unit_mobile[@<same>]`
  Example: `@web/webclient/settings_form_view/settings_form_view`. Add `/<test name>` to target one test.
- **Python:** `/<module>`, `/<module>:<TestClass>` or `/<module>:<TestClass>.<test_method>`.
  Python tests need the module installed in the DB. Add `-i <module>` only if it isn't installed.

## 4. Read the results

- Hoot prints `[HOOT] "<suite>" ended (passed: N / failed: M ...)` per suite, and for each failure `[HOOT] Test "<name>" failed:` followed by the assertion with `Expected`/`Received`.
- To debug, add a temporary `console.warn("DBG", ...)` in the code. It shows up as `WARNING ... browser: DBG ...`. Remove it afterwards.
- Report pass/fail counts per suite faithfully, with the failure details when something fails.
