function gow --description 'Create a new odoo/enterprise worktree pair via goo and launch ide.fish'
    set -l options (fish_opt -s b -l branch --long-only -r)
    argparse $options -- $argv

    if test (count $argv) -lt 1
        echo "usage: gow <version> <branch-description>" >&2
        echo "       gow <version> --branch <existing-branch-name>" >&2
        return 1
    end

    _goo_ensure_running

    set -l create_args $argv
    if set --query _flag_branch
        set create_args $argv[1] --branch $_flag_branch
    end

    set -l dir (python3 /home/jpp/src/goo/scripts/create_workspace.py $create_args)
    or return $status

    cd $dir; and ide.fish
end
