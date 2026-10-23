# Typing into a pane before its shell shows a prompt loses the keystrokes
function __herd_run
    for i in (seq 100)
        string match -q '*❯*' (herdr pane read $argv[1] 2>/dev/null | string collect); and break
        sleep 0.1
    end
    herdr pane run $argv >/dev/null
end

# Split a pane towards $2 in folder $3, named after it; prints the new pane's id
function __herd_split
    set -l p (herdr pane split $argv[1] --direction $argv[2] --cwd $argv[3] --no-focus | jq -r .result.pane.pane_id)
    herdr pane rename $p (basename $argv[3]) >/dev/null
    echo $p
end

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
    __herd_run $ids[3] nvim

    # git tab: one pane per repo folder (arguments; odoo + enterprise by default):
    # 1 alone, 2 stacked, 3+ in two columns (left n/2, right the rest), 4 = one per corner
    set -l repos $argv
    test (count $repos) -eq 0; and set repos $dir/odoo $dir/enterprise
    set -l n (count $repos)
    set -l git (herdr tab create --workspace $ws --cwd $repos[1] --label git --no-focus | jq -r .result.root_pane.pane_id)
    herdr pane rename $git (basename $repos[1]) >/dev/null
    set -l left $git
    set -l right
    if test $n -eq 2
        set right (__herd_split $git down $repos[2])
    else if test $n -gt 2
        set right (__herd_split $git right $repos[(math floor $n / 2 + 1)])
    end
    # stack the rest of each column under its first pane
    set -l nleft (math floor $n / 2)
    set -l col $left
    test $n -gt 2; and for i in (seq 2 $nleft)
        set col (__herd_split $col down $repos[$i])
    end
    set col $right
    for i in (seq (math $nleft + 2) $n)
        set col (__herd_split $col down $repos[$i])
    end

    # claude tab: typed into fish, so it resolves the sandboxed `claude` function
    set -l claude (herdr tab create --workspace $ws --cwd $dir --label claude --no-focus | jq -r .result.root_pane.pane_id)
    __herd_run $claude claude
end
