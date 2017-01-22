Wordpress SQL backups CLI
===================

This shell script allows you to **backup**, **restore** and **migrate** the database of your wordpress websites though command line.

##Quick demo
![Wordpress sql backups CLI demo](https://lh3.googleusercontent.com/-Uah0-RQW_NI/WITgWIipBwI/AAAAAAAADMk/lA_IjLRuhwoJQPinO3ucq-41GLpZNrhAwCLcB/s0/backup-wp.jpg "backup-wp.jpg")

##Installation
Copy the `wp-sql-backup` folder to the `wp-content` folder of your wordpress website

##How to

To use this file, you must be at the root of a wp folder and source it: 
```sh
$ source wp-content/wp-sql-backup/wp-sql-backup.sh
```
###Available commands
```sh
$ wp-sql-backup
```
Backup the database into a sql file in the format **dump_F_H-M-S .sql** 

```sh
$ wp-sql-migrate newSiteUrl
```
 Creates a database migration backup. The old url of the site will be replaced by the newDomain in the sql dump
 - `newSiteUrl`  full url of the new domain (with slash)

```sh
$ wp-sql-restore pathToSqlFile (or) last
```
 Restore a sql file into the database or restore the last backup created
 - `pathToSqlFile` The sql file to load.
 - `last` If you set last as pathToSqlFile, restore the last sql file created

```sh
$ wp-sql-list
```
Display the list of sql dumps

```sh
$ help
```
Display help

##Author
Developed by Isadora Bartkowiak.