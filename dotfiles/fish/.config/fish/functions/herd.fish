function herd --description 'ide, but a herdr workspace (editor, git, claude tabs) in one shared herdr window'
    set -l dir (pwd)
    set -l name (basename $dir)

    # One herdr window for everything: find the window whose process tree runs a
    # herdr client (however it was opened), walking up from each client's pid
    set -l windows (hyprctl clients -j | jq -r '.[] | "\(.pid) \(.address)"')
    set -l addr
    for p in (pgrep -x herdr)
        while test -z "$addr" -a "$p" -gt 1
            set addr (string match -r "^$p (.*)" -- $windows)[2]
            set p (ps -o ppid= -p $p | string trim)
        end
    end

    if test -n "$addr"
        hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })" >/dev/null
    else
        # None open: open one in an empty workspace (this also starts the server)
        hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "empty" }))' >/dev/null
        setsid foot herdr >/dev/null 2>&1 &
        while not herdr workspace list >/dev/null 2>&1
            sleep 0.1
        end
    end

    # Project already open: just jump to it
    set -l ws (herdr workspace list | jq -r --arg n $name '.result.workspaces[] | select(.label == $n) | .workspace_id' | head -1)
    if test -n "$ws"
        herdr workspace focus $ws >/dev/null
        return
    end

    # editor tab
    set -l ids (herdr workspace create --cwd $dir --label $name --focus | jq -r '.result.workspace.workspace_id, .result.tab.tab_id, .result.root_pane.pane_id')
    set ws $ids[1]
    herdr tab rename $ids[2] editor >/dev/null
    herdr pane run $ids[3] nvim >/dev/null

    # git tab: odoo on top, enterprise below
    set -l git (herdr tab create --workspace $ws --cwd $dir/odoo --label git --no-focus | jq -r .result.root_pane.pane_id)
    herdr pane split $git --direction down --cwd $dir/enterprise --no-focus >/dev/null

    # claude tab: typed into fish, so it resolves the sandboxed `claude` function
    set -l claude (herdr tab create --workspace $ws --cwd $dir --label claude --no-focus | jq -r .result.root_pane.pane_id)
    herdr pane run $claude claude >/dev/null
end
