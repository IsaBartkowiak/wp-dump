Wordpress sql dump shell script
===================

This shell script was created for **backup**, **restore** and **migrate** the database of your wordpress websites with command line.

##Installation
Copy the content of the bin folder at the root of your wordpress website

##How to

To use this file, you must be at the root of a wp folder and source it: 
```sh
$ source bin/wp_dump.sh
```
###Available commands :
```sh
$ wdHelp
```
Display help
```sh
$ wdBackup [oldDomain] [newDomain]
```
Dump the database into a sql file with the format **dump_F_H-M-S .sql** .
If the 2 parameters are set, oldDomain **will be replaced by newDomain into the sql file.**
`oldDomain` (optional) full url of the existing domain
`newDomain` (optional)  full url of the new domain

```sh
$ wdRestore pathToSqlFile || last
```
 Restore a sql file into the database or restore the last dump created
`pathToSqlFile` The sql file to load.
`last` If you set last as pathToSqlFile, restore the last sql file created

##Author
Developed by Isadora Bartkowiak.