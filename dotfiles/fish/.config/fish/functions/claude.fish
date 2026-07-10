function claude --description 'Run Claude Code inside a bubblewrap sandbox'
    if test (id -u) -eq 0
        echo "Do not run this as root" >&2
        return 1
    end

    set -l claude_bin "$HOME/.local/bin/claude"
    if not test -x "$claude_bin"
        echo "Claude Code not found at $claude_bin" >&2
        return 1
    end

    set -l claude_dirs "$HOME/.cache/claude" "$HOME/.cache/claude-cli-nodejs" "$HOME/.claude" "$HOME/.local/state/claude"
    for d in $claude_dirs
        mkdir -p $d
    end
    set -l claude_files "$HOME/.claude.json"
    for f in $claude_files
        test -e $f; or touch $f
    end

    set -l allow_dirs "$HOME/src/odoo-src" "$HOME/src/dev-config"
    set -l claude_args
    set -l i 1
    while test $i -le (count $argv)
        if test "$argv[$i]" = --add-dir
            set i (math $i + 1)
            set -a allow_dirs (realpath $argv[$i])
        else
            set -a claude_args $argv[$i]
        end
        set i (math $i + 1)
    end

    set -l bwrap_args \
        --bind "$HOME/.local/bin/claude" "$HOME/.local/bin/claude" \
        --bind "$HOME/.local/share/claude" "$HOME/.local/share/claude" \
        --ro-bind /run/systemd/resolve /run/systemd/resolve \
        --ro-bind /etc/hosts /etc/hosts \
        --ro-bind /etc/ssl /etc/ssl \
        --symlink ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf \
        --ro-bind /usr /usr \
        --symlink usr/bin /bin --symlink usr/sbin /sbin \
        --symlink usr/lib /lib --symlink usr/lib64 /lib64 \
        --ro-bind /etc/passwd /etc/passwd \
        --bind /var/run/docker.sock /var/run/docker.sock \
        --dev /dev --proc /proc --tmpfs /tmp \
        --chdir "$allow_dirs[1]" \
        --unshare-pid --unshare-ipc --unshare-uts --unshare-cgroup \
        --die-with-parent --new-session --hostname claude-sandbox

    for d in $claude_dirs $claude_files
        set -a bwrap_args --bind $d $d
    end
    for d in $allow_dirs
        set -a bwrap_args --bind $d $d
        set -a claude_args --add-dir $d
    end

    set -l forbidden "$HOME/.ssh" "$HOME/.gnupg" "$HOME/.config/gh" \
        "$HOME/.config/1Password" "$HOME/.config/Bitwarden" "$HOME/.mozilla" \
        "$HOME/.docker" "$HOME/.aws"
    for d in $forbidden
        if bwrap $bwrap_args -- test -e $d 2>/dev/null
            echo "FAIL: $d is reachable inside the sandbox, aborting" >&2
            return 1
        end
    end

    bwrap $bwrap_args -- "$claude_bin" $claude_args
end
