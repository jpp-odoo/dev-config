function claude --description 'Run Claude Code inside a bubblewrap sandbox'
    # Thin delegator: the bwrap sandbox logic lives in
    # ~/.local/libexec/agent-sandbox/claude (a plain bash script) so that
    # non-fish launchers of a bare `claude` (Omarchy's agent picker/
    # keybindings exec it directly, no shell involved) get the same sandbox
    # via PATH, instead of only fish users.
    ~/.local/libexec/agent-sandbox/claude $argv
end
