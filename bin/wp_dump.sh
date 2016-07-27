#!/usr/bin/env bash
# +----------------------------------------------------------------------+
# | Author: Isadora Bartkowiak <contact@isadora-bk.com>                  |
# +----------------------------------------------------------------------+

#  shell commands
#
# To use this file, you must be at the root of a wp folder and source it: 
#	$ source /bin/wp_dump.sh
#
#     wdHelp
#       Display this message.
#
#     wdBackup [oldDomain] [newDomain]
#       Dump the database. If [oldDomain newDomain] are set, oldDomain will be replaced by 
#       newDomain into the sql file, used for migration.
#       oldDomain (optional) full url of the existing domain
#       newDomain (optional)  full url of the new domain
#
#    wdRestore pathToSqlFile || last
#       Restore a sql file into the database or restore the last dump created
#       pathToSqlFile    The sql file to load.
#       last If you set last as pathToSqlFile, restore the last sql file created

function checkLocation {
    if [ ! -d wp-content ] || [ ! -f wp-config.php ]; then
        echo "Missing wp-content directory or wp-config.php file."
        echo "You must be at the root of an Wordpress website to launch this command."
        return 1
    fi
}

function setConstants {
    DUMP_PREFIX="dump_"
    BACKUP_FOLDER="backup/sql/" 

    DB_HOST=`cat wp-config.php | grep DB_HOST | cut -d \' -f 4`
    DB_NAME=`cat wp-config.php | grep DB_NAME | cut -d \' -f 4`
    DB_USER=`cat wp-config.php | grep DB_USER | cut -d \' -f 4`
    DB_PASS=`cat wp-config.php | grep DB_PASSWORD | cut -d \' -f 4`

    if [ "$DB_HOST" != "" ] && [ "$DB_NAME" != "" ] && [ "$DB_USER" != "" ]; then
        return 1
    else
        echo "Sorry there is a problem on your wp-config file"
        return 0
    fi
}

function atmSetup {
    if [ -z "$SETUP" ]; then
        # export constants
        export SETUP=1
        export NOW=`date +%F_%H-%M-%S`
        #create folder
        mkdir -p $BACKUP_FOLDER   
        #check if we are on root of wp project
        checkLocation || return 1
        #set access constants
        setConstants
        if [ $? -ne 1 ]; then
            clean
            return 1
        fi
    fi
    return 0
}

# cleanup environement
function clean {
    if [ -z "$SETUP" ] || [ $SETUP -eq 1 ]; then
        unset DB_HOST
        unset DB_NAME
        unset DB_USER
        unset DB_PASS
        unset SQL_DUMP_FILE
        unset DUMP_PREFIX
        unset FILE
        unset SETUP
    else
        SETUP=$(($SETUP - 1))
    fi
    return 0
}

function wdBackup {
    atmSetup || return 1

    # change prefix if it's a migration
    if [ ! -z "$1" ] && [ ! -z "$2" ]; then
        DUMP_PREFIX="migrate_"
    fi
    SQL_DUMP_FILE="$BACKUP_FOLDER$DUMP_PREFIX$NOW.sql"
    OPTIONS="--add-drop-table --complete-insert --result-file=$SQL_DUMP_FILE"

    # check if file must be overided
    if [ -f "$SQL_DUMP_FILE" ]; then
        echo "$SQL_DUMP_FILE already exists"
        ask "Overide $SQL_DUMP_FILE [Y|n]?" "n"
        if [ $? -ne 1 ]; then
            clean
            return 1
        fi
    fi

    # create the dump
    mysqldump -h$DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME $OPTIONS
    if [ $? -eq 0 ]; then
        echo "SUCCESS: file created at $SQL_DUMP_FILE"
        #find replace old domain new domain on sql
        if [ ! -z "$1" ] && [ ! -z "$2" ]; then
            DOMAIN1=$(echo "${1}" | sed 's/\//\\\//g')
            DOMAIN2=$(echo "${2}" | sed 's/\//\\\//g')
            sed -i "" "s/$DOMAIN1/$DOMAIN2/g" $SQL_DUMP_FILE
        fi
    else
        # clean files in case of failure
        echo "ERROR: SQL dump failure";
        if [ -f "$SQL_DUMP_FILE" ]; then
            rm "$SQL_DUMP_FILE"
        fi
    fi
    clean
}

function wdRestore {

    atmSetup || return 1

    if [ ! -f $1 ] && [ $1 != "last" ]; then
        echo "ERROR: file $1 do not exists"
        clean
        return 1
    fi

    if [ -f $1 ] && [ $1 != "last" ]; then
        FILE="$1"
    fi  

    if [ $1 = "last" ]; then
        FILE="$BACKUP_FOLDER"`cd $BACKUP_FOLDER && ls -1 | tail -n 1`
    fi

    echo "Loading database..."
    mysql -h$DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < "$FILE"
    if [ $? -eq 0 ]; then
        echo "SUCCESS: Database is successfully updated"
        clean
        return 0
    else
        echo "ERROR: SQL load failure";
        clean
        return 1
    fi

    clean
    return 0
}

function ask {
    wrong_answer=1
    while [ $wrong_answer -eq 1 ]; do
        echo -n "$1 "
        read answer
        if [ -z "$answer" ]; then
            answer="$2"
        fi
        case "$answer" in
            "y" | "Y" ) return 1;;
            "n" | "N" ) return 0;;
            "" ) wrong_answer=1;; esac
    done
}

function wdHelp {
    echo "WP Dump shell help.

     wdBackup [oldDomain] [newDomain]
        Dump the database. If [oldDomain newDomain] are set,
        oldDomain will be replaced by newDomain into the sql file.

        oldDomain (optional) full url of the existing domain
        newDomain (optional)  full url of the new domain

     wdRestore pathToSqlFile || last
        Restore a sql file into the database or restore the last dump created

        pathToSqlFile    The sql file to load.
        last If you set last as pathToSqlFile, restore the last sql file created
    "
}