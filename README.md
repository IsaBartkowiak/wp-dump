Wordpress SQL backups CLI
===================

This shell script allows you to **backup**, **restore** and **migrate** the database of your wordpress websites though command line.

## Quick demo

### Create wordpress sql backup
![Create sql backup](https://lh3.googleusercontent.com/Q8elOF4qtQOwFvLCd8TJO6Oja2EkM10axEGh-ZGUTZNwpAOQQ7RsBSiXiT45o-lCruSoONuR=s0 "wp-backup1.jpg")

### Create wordpress sql migration backup

![Create sql migration backup](https://lh3.googleusercontent.com/-Hhs4Di1d008/WIVFrLD2sjI/AAAAAAAADNQ/kC1YdkepAgYAFTE-TyGEBvL4vz7KrQQywCLcB/s0/wp-backup2.jpg "wp-backup2.jpg")

### Restore wordpress database to the last created backup
![Restore database to the last created backup](https://lh3.googleusercontent.com/-e9rmpnr5tyM/WIVGCPWZqwI/AAAAAAAADNY/hI6ulZG7VS0b8zOSxIgNawh_Ry2MZtx_wCLcB/s0/wp-backup3.jpg "wp-backup3.jpg")

### List all backups files

![List all backups files](https://lh3.googleusercontent.com/-gqvdXZsyQZI/WIVGHeCM9cI/AAAAAAAADNg/S_H2gSsZy1kk_Qgeyi2r2L3Axw6qZ_GeQCLcB/s0/wp-backup4.jpg "wp-backup4.jpg")

### Restore wordpress database from a backup url

![Restore wordpress database from a backup url](https://lh3.googleusercontent.com/u4dKwHzb4xMMv6y8tna-MrigdEKFDVTeK0L4XkAtcouvMu_XZQCUOUFHAurgGe5XVBxbGrB0=s0 "wp-backup.jpg")

## Installation
Copy the `wp-sql-backup` folder to the `wp-content` folder of your wordpress website

## How to

To use this file, you must be at the root of a wp folder and source it: 
```sh
$ source wp-content/wp-sql-backup/wp-sql-backup.sh
```

### Available commands

```
$ wp-sql-backup
```
Backup the database into a sql file in the format dump_F_H-M-S .sql 

```
$ wp-sql-migrate newSiteUrl
```
 Creates a database migration backup. The old url of the site will be replaced by the newDomain in the sql dump
 - *newSiteUrl*  : full url of the new domain (with slash)

```
$ wp-sql-restore pathToSqlFile (or) last
```
 Restore a sql file into the database or restore the last backup created
 - *pathToSqlFile* : The sql file to load.
 - *last* : If you set last as pathToSqlFile, restore the last sql file created

```
$ wp-sql-list
```
Display the list of sql dumps

```
$ help
```
Display help

## Author
Developed by Isadora Bartkowiak.