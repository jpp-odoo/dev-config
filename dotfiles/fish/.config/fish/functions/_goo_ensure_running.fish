function _goo_ensure_running --description 'Start goo (the odoo worktree dashboard) if not already reachable'
    if not curl -fsS -m 1 http://127.0.0.1:8068/api/config >/dev/null 2>&1
        echo "goo not running, starting it..." >&2
        mkdir -p ~/.local/state/goo
        setsid nohup python3 /home/jpp/src/goo/goo.py >> ~/.local/state/goo/server.log 2>&1 &
    end
end
