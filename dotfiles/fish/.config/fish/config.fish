atuin init fish | source
zoxide init fish | source
starship init fish | source
# fzf --fish | source

set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/gcr/ssh"

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

# Set default editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# Set Gemini API key from keyring
set -l GEMINI_KEY (secret-tool lookup unique "gemini-api-key")
if test -n "$GEMINI_KEY"
    set -gx GEMINI_API_KEY "$GEMINI_KEY"
end
