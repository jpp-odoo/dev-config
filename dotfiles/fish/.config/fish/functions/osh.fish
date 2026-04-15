function osh --description "Odoo SH installer"

    set -l options h-help 'f=' 'd=' #https://fishshell.com/docs/current/commands.html#argparse-option-specs

    argparse $options -- $argv

    if set --query _flag_help
        printf "Usage: osh -d database -f dump_file.zip(or dump_file.sql.gz)\n"
        return 0
    end

    if not set --query _flag_f
        printf "No dump file selected\n"
        return 1
    end

    if file --mime-type $_flag_f | grep application/gzip
        set _flag_type gz
    else if file --mime-type $_flag_f | grep application/zip
        set _flag_type zip
    else
        printf "Only gz and zip files are allowed\n"
        return 1
    end

    set db_prefix oe_support_
    set --query _flag_d; or set --local _flag_d bf
    set dbName "$db_prefix$_flag_d"

    if test "$_flag_type" = zip
        echo 'Unzip File'
        unzip -qq $_flag_f -d /tmp/$dbName
    end
    if test "$_flag_type" = gz
        echo 'Gzip File'
        mkdir /tmp/$dbName
        gzip -dfc $_flag_f >/tmp/$dbName/dump.sql
    end

    echo 'Cleaning previous DB'
    rm -rf ~/src/odoo-src/fileStorage/$dbName
    docker exec -it odoo-db dropdb -U odoo $dbName

    echo 'Create new DB'
    docker exec -it odoo-db createdb -U odoo $dbName

    echo 'Restore DB from dump'
    docker cp /tmp/$dbName/dump.sql odoo-db:/tmp/dump.sql
    docker exec -it odoo-db /bin/bash -c "psql -U odoo $dbName </tmp/dump.sql"
    docker exec -it odoo-db psql -U odoo -d $dbName -c "UPDATE ir_cron SET active = 'f'"
    # login admin whould have id=1 if Odoo <= 11
    docker exec -it odoo-db psql -U odoo -d $dbName -c "UPDATE res_users SET login ='admin' where id = 2"
    docker exec -it odoo-db psql -U odoo -d $dbName -c "UPDATE res_users SET password=login"
    docker exec -it odoo-db psql -U odoo -d $dbName -c "DELETE FROM ir_attachment WHERE name like '/web/content/%assets_%'"

    if test "$_flag_type" = zip
        echo 'Sync filestore'
        rsync -a /tmp/$dbName/filestore/ ~/src/odoo-src/fileStorage/$dbName
    end

    echo 'Clean tmp files'
    rm -rf /tmp/$dbName/

    echo Done

end
