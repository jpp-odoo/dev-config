function gow --description 'Create a new odoo/enterprise worktree pair (plain git) and launch ide.fish'
    set -l options (fish_opt -s b -l branch --long-only -r)
    argparse $options -- $argv

    if test (count $argv) -lt 1
        echo "usage: gow <version> <branch-description>" >&2
        echo "       gow <version> --branch <existing-branch-name>" >&2
        return 1
    end

    set -l odoo_src ~/src/odoo-src
    set -l odoo_version $argv[1]

    set -l branch
    set -l name
    if set --query _flag_branch
        set branch $_flag_branch
        set name (string replace -ra '[^a-zA-Z0-9._-]+' '-' -- $branch | string trim -c -)
    else
        if test (count $argv) -lt 2
            echo "usage: gow <version> <branch-description>" >&2
            return 1
        end
        set name (string replace -ra '[^a-zA-Z0-9._-]+' '-' -- "$odoo_version-$argv[2..-1]" | string trim -c -)
        set branch "$name-jpp"
    end

    set -l ws_dir "$odoo_src/$name"
    set -l i 2
    while test -e $ws_dir
        set name "$name-$i"
        set ws_dir "$odoo_src/$name"
        set i (math $i + 1)
    end

    set -l created_repos
    set -l created_paths
    set -l created_branches
    set -l failed_repos

    for repo in odoo enterprise
        set -l main_path "$odoo_src/master/$repo"
        set -l wt_path "$ws_dir/$repo"
        set -l attach 0

        if set --query _flag_branch
            if git -C $main_path rev-parse --verify --quiet "refs/heads/$branch" >/dev/null 2>&1
                set attach 1
            else if git -C $main_path ls-remote --exit-code --heads origin $branch >/dev/null 2>&1
                git -C $main_path fetch origin "$branch:$branch" >/dev/null 2>&1
                and set attach 1
            end
        end

        if test $attach -eq 1
            echo "$repo: attaching to existing branch $branch" >&2
            if git -C $main_path worktree add $wt_path $branch
                set -a created_repos $repo
                set -a created_paths $wt_path
                set -a created_branches ""
            else
                set -a failed_repos $repo
            end
        else
            echo "$repo: creating $branch off $odoo_version" >&2
            if git -C $main_path fetch origin $odoo_version
                and git -C $main_path worktree add -b $branch $wt_path FETCH_HEAD
                set -a created_repos $repo
                set -a created_paths $wt_path
                set -a created_branches $branch
            else
                set -a failed_repos $repo
            end
        end
    end

    if test (count $failed_repos) -gt 0
        echo "worktree creation failed for: $failed_repos" >&2
        for j in (seq (count $created_repos))
            echo "  rolling back $created_paths[$j]" >&2
            git -C "$odoo_src/master/$created_repos[$j]" worktree remove --force $created_paths[$j]
            if test -n "$created_branches[$j]"
                git -C "$odoo_src/master/$created_repos[$j]" branch -D $created_branches[$j]
            end
        end
        rmdir $ws_dir 2>/dev/null
        return 1
    end

    echo "name = \"$name\"" > "$ws_dir/odools.toml"
    echo "odoo_path = \"$ws_dir/odoo\"" >> "$ws_dir/odools.toml"
    echo "addons_paths = [\"$ws_dir/enterprise/\"]" >> "$ws_dir/odools.toml"
    echo "python_path = \"/usr/bin/python\"" >> "$ws_dir/odools.toml"

    cd $ws_dir
    and ide
end
