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

    set --query _flag_d; or set --local _flag_d bf

    if test "$_flag_type" = zip
        echo 'Unzip File'
        unzip -qq $_flag_f -d /tmp/$_flag_d
    end
    if test "$_flag_type" = gz
        echo 'Gzip File'
        mkdir /tmp/$_flag_d
        gzip -dfc $_flag_f >/tmp/$_flag_d/dump.sql
    end

    echo 'Cleaning previous DB'
    rm -rf ~/src/odoo-src/fileStorage/$_flag_d
    docker exec -it goo-postgres dropdb -U odoo $_flag_d

    echo 'Create new DB'
    docker exec -it goo-postgres createdb -U odoo $_flag_d

    echo 'Restore DB from dump'
    docker cp /tmp/$_flag_d/dump.sql goo-postgres:/tmp/dump.sql
    docker exec -it goo-postgres /bin/bash -c "psql -U odoo $_flag_d </tmp/dump.sql"
    docker exec -it goo-postgres psql -U odoo -d $_flag_d -c "UPDATE ir_cron SET active = 'f'"
    # login admin whould have id=1 if Odoo <= 11
    docker exec -it goo-postgres psql -U odoo -d $_flag_d -c "UPDATE res_users SET login ='admin' where id = 2"
    docker exec -it goo-postgres psql -U odoo -d $_flag_d -c "UPDATE res_users SET password=login"
    docker exec -it goo-postgres psql -U odoo -d $_flag_d -c "DELETE FROM ir_attachment WHERE name like '/web/content/%assets_%'"

    if test "$_flag_type" = zip
        echo 'Sync filestore'
        rsync -a /tmp/$_flag_d/filestore/ ~/src/odoo-src/fileStorage/$_flag_d
    end

    echo 'Clean tmp files'
    rm -rf /tmp/$_flag_d/

    echo Done

end
