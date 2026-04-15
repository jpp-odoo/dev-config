function co

    set repo (basename (dirname (git rev-parse --show-toplevel)))
    set baseversion (string replace -r "\-.*" "" -- (basename (git rev-parse --show-toplevel)))

    if count $argv > /dev/null
        set branch (string replace -r ".*:" "" -- $argv)
        git fetch $repo-dev $branch -q
        git checkout $branch -q
    else
        git checkout $baseversion -q
    end

end