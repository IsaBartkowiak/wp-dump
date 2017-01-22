#!/usr/bin/env bash
# +----------------------------------------------------------------------+
# | Author: Isadora Bartkowiak <contact@isadora-bk.com>                  |
# +----------------------------------------------------------------------+

function checkLocation {
    if ! test -d wp-content || ! test -f wp-config.php; then
        echo "Missing wp-content directory or wp-config.php file."
        echo "You must be at the root of an Wordpress website to launch this command."
       return 1
    fi
    return 0
}

function setConstants {
    export NOW=`date +%F_%H-%M-%S`
    BACKUP_FOLDER="wp-content/wp-sql-backup/backups/"
    
    DB_HOST=`cat wp-config.php | grep DB_HOST | cut -d \' -f 4`
    DB_NAME=`cat wp-config.php | grep DB_NAME | cut -d \' -f 4`
    DB_USER=`cat wp-config.php | grep DB_USER | cut -d \' -f 4`
    DB_PASS=`cat wp-config.php | grep DB_PASSWORD | cut -d \' -f 4`
    
    if test -z "$DB_HOST" && test -z "$DB_NAME" && test -z "$DB_PASS" && test -z "$DB_USER"; then
        clean
        echo "Error with wp-config file"
        return 1
    fi
    return 0
}

function setup {
    checkLocation || return 1
    setConstants || return 1
    checkServer || return 1
    export SETUP=1
    
    #create folder and file
    mkdir -p $BACKUP_FOLDER
    echo "<configuration>
<system.webServer>
<authorization>
<deny users="*" />
</authorization>
</system.webServer>
</configuration>" > $BACKUP_FOLDER"web.config"
    return 0
}

# clean environement
function clean {
    if test -z "$SETUP" || test $SETUP -eq 1 ; then
        unset DB_HOST
        unset DB_NAME
        unset DB_USER
        unset BACKUP_FOLDER
        unset DB_PASS
        unset NOW
        unset SQL_DUMP_FILE
        unset SETUP
    fi
    return 1
}

function checkServer {
    UP=$(pgrep mysql | wc -l);
    if [ "$UP" -ne 1 ]; then
        echo "Error: MySQL is not running"
        clean
        return 1
    fi
    return 0
}

function wp-sql-backup {
    setup || return 1
  
    SQL_DUMP_FILE=$BACKUP_FOLDER"dump_"$NOW".sql"
    OPTIONS="--add-drop-table --complete-insert --result-file=$SQL_DUMP_FILE"

    # create the dump
    mysqldump -h$DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME $OPTIONS
    if [ $? -eq 0 ]; then
        echo "SUCCESS: file created at $SQL_DUMP_FILE"
    else
        # clean files in case of failure
        echo "ERROR: SQL dump failure";
        if [ -f "$SQL_DUMP_FILE" ]; then
            rm "$SQL_DUMP_FILE"
        fi
    fi
    clean
}

function wp-sql-migrate {
    if test $# -ne 1; then
        echo "Error: The first argument has to be the target domain"
        help
        return 1
    fi 
    
    setup || return 1
      
    SQL_DUMP_FILE=$BACKUP_FOLDER"migrate_"$NOW".sql"
    OPTIONS="--add-drop-table --complete-insert --result-file=$SQL_DUMP_FILE"

    mysqldump -h$DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME $OPTIONS  
    origin=`cat $SQL_DUMP_FILE | grep siteurl | cut -d \' -f 4`
    
    echo "Migrate from $origin to $1"

    if [ $? -eq 0 ]; then
        echo "SUCCESS: file created at $SQL_DUMP_FILE"
         #find replace old domain new domain on sql file
        if test $# -eq 1; then
            DOMAIN1=$(echo "${origin}" | sed 's/\//\\\//g')
            DOMAIN2=$(echo "${1}" | sed 's/\//\\\//g')
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

function wp-sql-restore {
    setup || return 1
    filename=""
    
    if test $# -ne 1; then
        echo "Error: you must enter at least one parameter"
        return 1
    fi
    
    #if it's an existing file
    if test -f $1 ; then
        filename="$1"
    fi     
    
    #if we have to take the last backup
    if [ $1 = "last" ]; then
        filename="$BACKUP_FOLDER"`cd $BACKUP_FOLDER && ls -1 *.sql | tail -n 1`
    fi
        
    #if file not exists
    if ! test -f $filename || test -z $filename; then
        echo "ERROR: file do not exists"
        clean
        return 1
    fi
    
    #restore
    echo "Restore database from $filename"
    mysql -h$DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < "$filename"
    if [ $? -eq 0 ]; then
        echo "SUCCESS: Database successfully updated"
    else
        echo "ERROR: SQL load failure";
    fi

    clean
}

function wp-sql-list {
    BACKUP_FOLDER="wp-content/wp-sql-backup/backups/"
    tmp=$(pwd)
    count=0
    cd $BACKUP_FOLDER
    for file in `ls  -1 -d *.sql`; do
        echo $BACKUP_FOLDER$file
        ((count++))
    done
    if test $count = 0; then
        echo "No dump available"
    fi
    cd $tmp
    clean
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

function help {
    echo "
    WP Dump shell help.
    
    $ wp-sql-list
    Display the list of sql dumps
    
    $ wp-sql-backup
    Create sql dump file on backup folder

    $ wp-sql-migrate newSiteUrl
    Creates a database migration backup. The old url of the site will be replaced 
    by the newDomain in the sql dump.
    newSiteUrl : The target site url with the ending slash.
    
    $ wp-sql-restore [pathToFile] or last
    Restore a sql file into the database or restore the last dump created.
    pathToFile :  The sql file to load.
    last : If you set last as pathToSqlFile, restore the last sql file created    
    "
}