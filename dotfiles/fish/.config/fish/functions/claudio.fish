function claudio --wraps='~/.local/bin/claude' --description 'alias claudio=~/.local/bin/claude'
    # Unsandboxed: show it as "claudio" in herdr's agent list
    if set -q HERDR_PANE_ID
        herdr pane report-metadata $HERDR_PANE_ID --source claudio --agent claude --display-agent claudio >/dev/null
    end
    # CLAUDIO=1: a SessionStart hook records the session, so the sandboxed
    # claude wrapper hands `--resume <id>` (e.g. herdr restore) back to claudio
    CLAUDIO=1 ~/.local/bin/claude $argv
end
