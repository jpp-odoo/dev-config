#!/usr/bin/env bash
# Opens Hunk in a new herdr tab and blocks until the user quits it. Hunk keeps its notes in a live
# session that is gone once the window closes, so the user's comments are polled while it is open
# and the last snapshot is printed on exit.
set -e -u -o pipefail

HERDR_BIN="${HERDR_BIN:-herdr}"
JQ_BIN="${JQ_BIN:-jq}"

usage() {
  echo "Usage: $(basename "$0") <repo-directory> [-- hunk-args...]   (default hunk-args: diff)"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then usage; exit 0; fi
if [[ "${HERDR_ENV:-}" != "1" ]]; then echo "Not running inside a Herdr-managed pane" >&2; exit 1; fi

target_dir="${1:-.}"
shift || true
[[ "${1:-}" == "--" ]] && shift
[[ $# -gt 0 ]] || set -- diff
[[ -d "$target_dir" ]] || { echo "Directory not found: $target_dir" >&2; exit 1; }
target_dir=$(cd "$target_dir" && pwd)

snapshot=$(mktemp /tmp/hunk-comments.XXXXXX)
new_pane_id=""
poller=""
cleanup() {
  [[ -z "$poller" ]] || kill "$poller" 2>/dev/null || true
  [[ -z "$new_pane_id" ]] || "$HERDR_BIN" pane close "$new_pane_id" >/dev/null 2>&1 || true
  rm -f "$snapshot" "$snapshot.new"
}
trap cleanup EXIT

new_pane_id=$("$HERDR_BIN" tab create --cwd "$target_dir" --label "review $(basename "$target_dir")" --focus |
  "$JQ_BIN" -er '.result.root_pane.pane_id')

quoted_hunk=$(printf ' %q' "$(command -v hunk)" "$@")
quoted_hunk=${quoted_hunk# }
suffix="_DONE_$$_${RANDOM}__"
inner="$quoted_hunk; printf \"\\n__HUNK%s:%s\\n\" $suffix \$?"
# the pane's shell may be fish: hand it one single-quoted argument for bash -c
"$HERDR_BIN" pane run "$new_pane_id" "bash -c '${inner//\'/\'\\\'\'}'" >/dev/null

(
  while sleep 1; do
    if out=$(hunk session comment list --repo "$target_dir" --type user --json 2>/dev/null); then
      printf '%s' "$out" >"$snapshot.new" && mv "$snapshot.new" "$snapshot"
    fi
  done
) &
poller=$!

# fails when the user closes the tab instead of quitting hunk: the snapshot is printed either way
"$HERDR_BIN" pane wait-output "$new_pane_id" --match "__HUNK$suffix" --source recent-unwrapped >/dev/null 2>&1 || true
kill "$poller" 2>/dev/null || true
poller=""

echo "=== HUNK COMMENTS ($target_dir) ==="
if [[ -s "$snapshot" ]]; then cat "$snapshot"; echo; else echo "(none)"; fi
echo "=== END HUNK COMMENTS ==="
