atuin init fish | source
zoxide init fish | source
starship init fish | source

set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/gcr/ssh"

# The keyring may be locked (autologin) and secret-tool/ssh-add then wait for a prompt.
# The SDDM session start runs a non-interactive login fish, so keep them interactive-only.
if status is-interactive
    # 1. Retrieve the password from secret-tool
    # In Fish, we use (command) for substitution and 'set' for assignment
    set -l PASS (secret-tool lookup unique "ssh-store:$HOME/.ssh/id_ed25519")

    # 2. Check if the variable is non-empty
    # Fish uses 'if test -n' instead of Bash's '[ -n ]'
    if test -n "$PASS"
        # 3. Add the key using the stored password
        # We use 'echo $PASS' and pipe it into 'ssh-add'
        echo "$PASS" | ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null
    end

end

# Set default editor
set -gx EDITOR nvim
set -gx VISUAL nvim
