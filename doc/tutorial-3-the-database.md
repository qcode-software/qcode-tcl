
Tutorial 3: The Database
========
part of [Qcode Documentation](index.md)

-----

### Introduction

This tutorial will guide you through connecting and initialising the database for use with Qcode Tcl.
A list of data model dependencies can be viewed [here](/doc/data-model-dependencies.md).

-----
### Prerequisites

After installing and configuring [Postgresql database and users](/doc/postgresql-setup.md), install postgres-contrib:

```
apt-get install postgresql-contrib-9.4
```

Connect to Postgresql as superuser
```
$ sudo su - postgres
$ psql
```

Create a new database called "test" for the user "web".
```sql
postgres=# create role "web" with superuser login password 'pass123';
postgres=# create database "test" owner "web";
```


#### Set postgresql and controlport
Now we need to modify your Naviserver config to set the parameters for postgresql and the controlport. 

Ensure you have installed the naviserver DB drivers by this point:
```
sudo apt-get install naviserver-nsdbpg
```

To make sure it all works replace your full config file with [full config](/doc/qc-config.tcl)

You can find more about the configurations at the bottom of your new file.

The other part is the controlport. You can find the details and comments about it [full config file](/doc/naviserver-config-full.md) or the [naviserver API documentation](https://naviserver.sourceforge.io/n/nscp/files/nscp.html)

Dont forget to update your config.env, if you use the same host and port as the example config make sure the .env looks like this:
```
OPTS="-b 127.0.0.1:80"
```

## Initialising the database
Use either telnet or nc(netcat) to your control port.

(netcat handles cutting and pasting of line continuation characters better than telnet)
```
#| Telnet
telnet 127.0.0.1 9980
#| netcat
nc 127.0.0.1 9980
#| same same, but different but still same!

Login: nsd
Password: x
```

Telnet to your control port. Type the following commands:

```tcl
> package require qcode
> qc::db_init
```

Connect to the database as user "web" using psql
```
$ psql -U web -h localhost test
```

This is the command you should use whenever you wish to access this database with psql.


Check that the following tables have been created using the psql command `\dt`

```
Schema |        Name         | Type  |  Owner
--------+---------------------+-------+----------
public | file                | table | web
public | file_alias_path     | table | web
public | image               | table | web
public | optional            | table | web
public | param               | table | web
public | perm                | table | web
public | perm_category       | table | web
public | perm_class          | table | web
public | required            | table | web
public | schema              | table | web
public | session             | table | web
public | sticky              | table | web
public | user_perm           | table | web
public | users               | table | web
public | validation_messages | table | web
```

As Postgres superuser lower privileges for user web.

```sql
postgres=# alter role "web2" with nosuperuser;
```
