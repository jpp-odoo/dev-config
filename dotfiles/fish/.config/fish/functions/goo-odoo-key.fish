function goo-odoo-key --description "set (or --remove) the Odoo API key of the goo service"
    # The key goes into a systemd drop-in outside any repo, never into fish's variables or history.
    set -l dir $HOME/.config/systemd/user/goo.service.d
    set -l file $dir/odoo-key.conf

    if test "$argv[1]" = --remove
        rm -f $file
    else
        read -s -P 'Odoo API key (hidden): ' key
        echo
        if not string match -qr '^[A-Za-z0-9_-]+$' -- "$key"
            echo "goo-odoo-key: that does not look like an API key (letters, digits, - and _ only)" >&2
            return 1
        end
        mkdir -p $dir
        begin
            umask 077
            printf '[Service]\nEnvironment="GOO_ODOO_API_KEY=%s"\n' $key >$file
        end
        chmod 600 $file
    end

    systemctl --user daemon-reload
    systemctl --user restart goo.service
    echo "goo restarted"

    # ask goo whether it now sees a key Odoo accepts (needs "show Odoo task stage" on)
    for i in (seq 20)
        curl -s -o /dev/null -m 2 http://127.0.0.1:8068/ && break
        sleep 0.5
    end
    set -l reply (curl -s -m 20 -X POST -H 'content-type: application/json' -d '{"ids":[]}' http://127.0.0.1:8068/api/tasks)
    if string match -q '*"ok": true*' -- $reply
        echo "✓ the key works"
    else
        echo $reply | string match -rq '"error": "([^"]*)"'
        and echo "✗ "(echo $reply | string match -r '"error": "([^"]*)"')[2]
        or echo "✗ goo did not answer"
    end
end
