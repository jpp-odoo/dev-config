#!/bin/bash
# Run Odoo tests of a workspace in a throwaway container using Goo's image, network and Postgres.
# Usage: odoo-test.sh <workspace> <db> '<test-tags>' [extra odoo-bin args, e.g. -i <module>]
# Prints only the per-suite results and the failures. Needs a long timeout (up to 600000 ms).
set -eu
ws=$1 db=$2 tags=$3; shift 3
src=/home/jpp/src/odoo-src
path=addons; [ -d "$src/$ws/enterprise" ] && path=$path,../enterprise
docker run --rm --network goo_odoo --user odoo_user --workdir /src/odoo \
  -v "$src/$ws":/src -v /home/jpp/src/goo/addons:/goo-addons:ro \
  -v "$src/fileStorage":/home/odoo_user/.local/share/Odoo/filestore \
  noble python3 /src/odoo/odoo-bin --db_host goo-postgres --db_port 5432 -r odoo -w odoo \
  -d "$db" --addons-path "$path,/goo-addons" --dev all --stop-after-init --http-port 8070 \
  --test-tags "$tags" "$@" 2>&1 | awk '
  /failed:|FAIL:|ERROR/ { n = 6 }
  n > 0 { print substr($0, 1, 400); n--; next }
  /" ended \(|Test suite|Passed [0-9]|of [0-9]+ tests/ { print substr($0, 1, 400) }'
