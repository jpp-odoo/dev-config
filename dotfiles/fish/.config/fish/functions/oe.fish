function oe --description "Odoo Server"
    #https://fishshell.com/docs/current/commands.html#argparse-option-specs
    #https://fishshell.com/docs/current/cmds/fish_opt.html

    set -l options (fish_opt -s h -l help --long-only)
    set options $options (fish_opt -s e)
    set options $options (fish_opt -s f -l debug --long-only)
    set options $options (fish_opt -s a -l design --long-only)
    set options $options (fish_opt -s r -l tutorial --long-only)
    set options $options (fish_opt -s g -l upgrade --long-only)
    set options $options (fish_opt -s d -r)
    set options $options (fish_opt -s s -l shell --long-only)
    set options $options (fish_opt -s l -l log --long-only -r)
    set options $options (fish_opt -s k -l addons --long-only)
    set options $options (fish_opt -s i -r)
    set options $options (fish_opt -s u -r)
    set options $options (fish_opt -s b -l drop --long-only)
    set options $options (fish_opt -s t -l test -o)
    set options $options (fish_opt -s z -l tags --long-only -r)
    set options $options (fish_opt -s n -l no_demo --long-only)
    set options $options (fish_opt -s x -l stop --long-only)
    set options $options (fish_opt -s w -l JSTest --long-only)
    set options $options (fish_opt -s o -l logfile --long-only -o)

    argparse $options -- $argv

    if set --query _flag_help
        printf "Usage: oe [OPTIONS]\n\n"
        printf "Options:\n"
        printf "  --help                Prints help and exits\n"
        printf "  -e                    Enterprise\n"
        printf "  --debug               Add debugpy to debug the Python code\n"
        printf "  --design              Add the design-themes repo\n"
        printf "  --tutorial            Add the tutorial repo\n"
        printf "  --upgrade             Add the upgrade and upgrade-util repo\n"
        printf "  -d                    Database to use (default: the branch name checked out in ./odoo)\n"
        printf "  --shell                Open the shell for the selected Database\n"
        printf "  --log                 --log-level=xxx (default : --log-level=warn)\n"
        printf "  --addons              Path to the addons\n"
        printf "  -i                    install modules\n"
        printf "  -u                    update modules\n"
        printf "  --drop                drop DB before start server (if -u xx then -i xx)\n"
        printf "  -t or --test          --test-enable (if params then --test-enable -u xxx)\n"
        printf "  --tags                --test-tags=xx only if test is enable\n"
        printf "  --no_demo             --without-demo=all\n"
        printf "  --stop                --stop-after-init\n"
        printf "  --JSTest              JS Tests, stop after init\n"
        printf "  --logfile[=NAME]      Write server output to ~/src/odoo-src/log/NAME (default: <db>.log)\n"
        return 0
    end

    set OdooVersion (path basename (pwd))
    # Find which ubuntu for each OdooVersion for the moment use : prefix-match
    # since a workspace dir is now "<version>-<branch-desc>", not just "<version>"
    switch $OdooVersion
        case "16.0*" "17.0*"
            # 16.0, 17.0 -> ubuntu:jammy
            set ubuntuVersion jammy
        case "18.0*" "saas-18*" "19.0*" "saas-19*" "master*"
            # 18.0, saas-18.*, 19.0, saas-19.*, master -> ubuntu:noble
            set ubuntuVersion noble
        case "*"
            set ubuntuVersion noble
    end

    # --- Start Global Services ----
    if not docker ps --format '{{.Names}}' | grep -q db
        echo "Global Services (DB/Proxu) not running. Starting them ..."
        set -l runGlobal docker-compose -f ~/src/dev-config/dockerFiles/docker-compose.yml up -d
        echo "running : $runGlobal"
        eval $runGlobal
        echo "Waiting for DB..."
        sleep 3
    end

    # one container per branch (unlimited concurrent servers, not a fixed
    # odoo/odoo2 pair) - the branch name is unique by construction (the -jpp
    # naming convention), so it doubles as container name, db name, and the
    # nginx vhost (http://<branch>.localhost/, see dockerFiles/nginx.conf)
    set containerName (git -C odoo rev-parse --abbrev-ref HEAD)
    if test (docker inspect -f '{{.State.Running}}' $containerName 2>/dev/null) = true
        echo "already running: http://$containerName.localhost/"
        return 0
    end

    set imageName "$ubuntuVersion"

    # --- Image Check ---
    if not docker image inspect $ubuntuVersion >/dev/null 2>&1
        echo "Building missing image: $ubuntuVersion"
        set -l buildBase docker build -f "~/src/dev-config/dockerFiles/images/$ubuntuVersion.dockerfile" -t $ubuntuVersion ~/src/dev-config/dockerFiles/images/
        echo "running : $buildBase"
        eval $buildBase
    end

    # debugpyPort should be here also -p ..:...
    # DISPLAY/X11 socket are forwarded so headed Chrome (browser_js watch=True/debug tours) renders directly on the host, no VNC needed
    set python "docker run --rm -it --privileged --shm-size=1g --network odoo_dev --name $containerName -e HOST=db -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:rw -v ~/src/odoo-src/:/src -v ~/src/odoo-src/fileStorage/:/home/odoo_user/.local/share/Odoo/filestore $imageName python3"
    set odoo $python

    if not set --query _flag_JSTest; and set --query _flag_debug
        set -a odoo "-Xfrozen_modules=off -m debugpy --listen 0.0.0.0:5678 --wait-for-client"
    end

    set addons
    if set --query _flag_addons
        set -a addons $_flag_addons
    end

    if set --query _flag_design
        set -a addons /src/design-themes
    end
    if set --query _flag_tutorial
        set -a addons src/$OdooVersion/tutorials
    end
    if set --query _flag_e
        set -a addons "/src/$OdooVersion/enterprise"
    end

    set addons (eval string join ',' $addons)
    if test -n "$addons"
        set addons ",$addons"
    end

    set -a odoo "/src/$OdooVersion/odoo/odoo-bin"

    set -a odoo "--addons-path=/src/$OdooVersion/odoo/addons,/src/$OdooVersion/odoo/odoo/addons$addons"

    if set --query _flag_upgrade
        set -a odoo "--upgrade-path=/src/upgrade-util/src,/src/upgrade/migrations"
        set _flag_u all
        set _flag_stop
    end

    if set --query _flag_JSTest
        set _flag_d web_tests
        set _flag_drop
        set _flag_stop
        set _flag_t
        set _flag_tags ":WebSuite.test_unit_desktop"
        set _flag_log info
        if set --query _flag_e
            set _flag_i web_studio
        end
    end
    set --query _flag_d; or set _flag_d $containerName
    set dbName "$_flag_d"
    set -a odoo "-d $dbName --db-filter='^$dbName' --db_host=db --db_user=odoo --db_password=odoo"

    if set --query _flag_logfile
        mkdir -p ~/src/odoo-src/log
        set -l logname "$_flag_logfile"
        test -n "$logname"; or set logname "$dbName.log"
        set -a odoo "--logfile=/src/log/$logname"
    end

    if set --query _flag_log
        set -a odoo "--log-level=$_flag_log"
    else
        set -a odoo "--log-level=warn"
    end

    if set --query _flag_i
        set -a odoo "-i $_flag_i"
    end

    if set --query _flag_u
        if set --query _flag_drop
            set -a odoo "-i $_flag_u"
        else
            set -a odoo "-u $_flag_u"
        end
    end

    set drop "docker exec -it odoo-db dropdb -U odoo $dbName"
    set dropFilestore "rm -rf ~/src/odoo-src/fileStorage/$dbName"

    if set --query _flag_t
        if test -z "$_flag_t"
            set -a odoo --test-enable
        else
            if set --query _flag_drop
                set -a odoo "--test-enable -i $_flag_t"
            else
                set -a odoo "--test-enable -u $_flag_t"
            end
        end
        if set --query _flag_tags
            set -a odoo "--test-tags=$_flag_tags"
        end
    end

    if set --query _flag_no_demo
        set -a odoo "--without-demo=all"
    else
        switch $OdooVersion
            case "16.0*" "17.0*" "18.0*" "saas-17*" "saas-18*"
                # default is with demo, no flag needed
            case "*"
                # master/19.0+: default changed to no demo, explicitly re-enable with inverted flag
                set -a odoo "--without-demo=False"
        end
    end

    if set --query _flag_stop
        set -a odoo --stop-after-init
    end

    # no idea why, but this is necessary since : https://github.com/odoo/odoo/commit/fd2bc6e525bfc32fe5a3b3ccae1752fd44cba26e
    set -a odoo "--http-interface=0.0.0.0"
    set -a odoo "--limit-time-cpu=9999999999 --limit-time-real=9999999999 $argv[2..-1]"

    # This should be at the begining !
    if set --query _flag_shell
        eval $python /src/$OdooVersion/odoo/odoo-bin shell --addons-path=/src/$OdooVersion/odoo/addons,/src/$OdooVersion/enterprise --db_host=db --db_user=odoo --db_password=odoo -d $dbName
    else
        if set --query _flag_drop
            set_color green
            echo $drop
            set_color Normal
            eval $drop
            set_color green
            echo $dropFilestore
            set_color Normal
            eval $dropFilestore
        end
        set_color green
        echo $odoo
        set_color Normal
        eval $odoo
    end
end
