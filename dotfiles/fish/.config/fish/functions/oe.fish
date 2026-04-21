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
    set options $options (fish_opt -s c -l tour --long-only)
    set options $options (fish_opt -s n -l no_demo --long-only)
    set options $options (fish_opt -s x -l stop --long-only)
    set options $options (fish_opt -s w -l JSTest --long-only)

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
        printf "  -d                    Database to use with prefix oe_support_ (default oe_support_{vesion})\n"
        printf "  -shell                Open the shell for the selected Database\n"
        printf "  --log                 --log-level=xxx (default : --log-level=warn)\n"
        printf "  --addons              Path to the addons\n"
        printf "  -i                    install modules\n"
        printf "  -u                    update modules\n"
        printf "  --drop                drop DB before start server (if -u xx then -i xx)\n"
        printf "  -t or --test          --test-enable (if params then --test-enable -u xxx)\n"
        printf "  --tour                enable vnc on the container to show the tour\n"
        printf "  --tags                --test-tags=xx only if test is enable\n"
        printf "  --no_demo             --without-demo=all\n"
        printf "  --stop                --stop-after-init\n"
        printf "  --JSTest              JS Tests, stop after init\n"
        return 0
    end

    set db_prefix oe_support_

    set OdooVersion (path basename (pwd))
    # Find which ubuntu for each OdooVersion for the moment use :
    switch $OdooVersion
        case "16.0" "17.0"
            # 16.0, 17.0 -> ubuntu:jammy
            set ubuntuVersion jammy
        case "18.0" "saas-18*" "19.0" "saas-19*" master
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

    # if podman container exists odoo
    if docker container inspect odoo >/dev/null 2>&1
        set containerName odoo2
        set debugpyPort 5679
        set vncPort 5901
    else
        set containerName odoo
        set debugpyPort 5678
        set vncPort 5900
    end

    # Change this to ubuntu names and versions !
    if set --query _flag_tour
        set imageName "$ubuntuVersion-vnc"
    else
        set imageName "$ubuntuVersion"
    end

    # --- Image Check ---
    if not docker image inspect $ubuntuVersion >/dev/null 2>&1
        echo "Building missing image: $ubuntuVersion"
        set -l buildBase docker build -f "~/src/dev-config/dockerFiles/images/$ubuntuVersion.dockerfile" -t $ubuntuVersion ~/src/dev-config/dockerFiles/images/
        echo "running : $buildBase"
        eval $buildBase
    end
    if set --query _flag_tour; and not docker image inspect $imageName >/dev/null 2>&1
        echo "Building missing image: $imageName"
        set -l buildVnc docker build -f "~/src/dev-config/dockerFiles/images/vnc.dockerfile" --build-arg "BASE_IMAGE=$ubuntuVersion" -t $imageName ~/src/dev-config/dockerFiles/images/
        echo "running : $buildVnc"
        eval $buildVnc
    end

    # Port 5900 is for vnc ... maybe put it in odoo or odoo2 and change it
    # debugpyPort should be here also -p ..:...
    set python "docker run --rm -it --privileged --network odoo_dev --name $containerName -e HOST=db -e DISPLAY=:0 -p 5900:5900 -v ~/src/odoo-src/:/src -v ~/src/odoo-src/fileStorage/:/home/odoo_user/.local/share/Odoo/filestore $imageName python3"
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
    set --query _flag_d; or set _flag_d $OdooVersion
    set dbName "$db_prefix$_flag_d"
    set -a odoo "-d $dbName --db-filter='^$dbName' --db_host=db --db_user=odoo --db_password=odoo"

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
        set -a odoo "--without-demo=True"
    else
        set -a odoo "--without-demo=False"
    end

    if set --query _flag_stop
        set -a odoo --stop-after-init
    end

    # no idea why, but this is necessary since : https://github.com/odoo/odoo/commit/fd2bc6e525bfc32fe5a3b3ccae1752fd44cba26e
    set -a odoo "--http-interface=0.0.0.0"
    set -a odoo "--limit-time-cpu=9999999999 --limit-time-real=9999999999 $argv[2..-1]"

    # This should be at the begining !
    if set --query _flag_shell
        $python /src/$OdooVersion/odoo/odoo-bin shell --addons-path=/src/$OdooVersion/odoo/addons,/src/$OdooVersion/enterprise --db_host=db --db_user=odoo --db_password=odoo -d $dbName
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
