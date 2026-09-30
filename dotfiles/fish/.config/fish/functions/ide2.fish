function ide2 --description 'ide, but a tabbed Ghostty window instead of a tmux session'
    set -l dir (pwd)
    set -l daemon (pgrep -f '^/usr/bin/ghostty --gtk-single-instance')

    set -l n (count (pgrep -P $daemon))
    ghostty +new-window --working-directory="$dir" -e nvim
    while test (count (pgrep -P $daemon)) -le $n
        sleep 0.1
    end

    # git tab: new tab, cd into odoo, split down into enterprise
    set n (count (pgrep -P $daemon))
    wtype -M ctrl -M shift -k t -m shift -m ctrl
    while test (count (pgrep -P $daemon)) -le $n
        sleep 0.1
    end
    wtype -- "cd $dir/odoo; clear" && wtype -k Return

    set n (count (pgrep -P $daemon))
    wtype -M ctrl -M shift -k e -m shift -m ctrl
    while test (count (pgrep -P $daemon)) -le $n
        sleep 0.1
    end
    wtype -- "cd $dir/enterprise; clear" && wtype -k Return

    # claude tab: new tab, cd into project root, run claude through the real shell
    # (so it resolves the sandboxed `claude` fish function, not the raw binary)
    set n (count (pgrep -P $daemon))
    wtype -M ctrl -M shift -k t -m shift -m ctrl
    while test (count (pgrep -P $daemon)) -le $n
        sleep 0.1
    end
    wtype -- "cd $dir; claude" && wtype -k Return
end
