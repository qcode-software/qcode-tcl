
Tutorial 3: The Database
========
part of [Qcode Documentation](index.md)

-----

### Introduction

This tutorial will guide you through connecting and initialising the database for use with Qcode Tcl.
A list of data model dependencies can be viewed [here](/doc/data-model-dependencies.md).

-----
### Prerequisites

After installing [Postgresql](/doc/postgresql-setup.md) install postgres-contrib:

```
apt-get install postgresql-contrib-9.4
```

Create a blank database called `test`.

#### Set postgresql and controlport
Now we need to modiyfy your naviserver config to set the parameters for postgresql and a controlport. 
To make sure it all works replace your full config file with [full config](/doc/qc-config.tcl)

You can find more about the configurations at the bottom of your new file.

The other part is the controlport. You can find the details and comments about it [full config file](/doc/naviserver-config-full.md) or the [naviserver API documentation](https://naviserver.sourceforge.io/n/nscp/files/nscp.html)

Dont forget to update your config.env, if you use the same host and port as the example config make sure the .env looks like this:
```
OPTS="-b 127.0.0.1:80"
```

## Initialising the database
Use either telnet or nc(netcat) to your control port.
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

The final command should return nothing indicating that the data structure has been successfully set up.

You may receive an error message from the module PgCrypto stating that the database user "www-data" is not superuser. 

To correct this:

* 1) switch to the postgres user `sudo su - postgres`
* 2) Assign the user "www-data" superuser privilidges `ALTER USER "www-data" WITH SUPERUSER;`
* 3) Run the above `db_init` code.
* 4) Remove superuser priviledges from "www-data" user `ALTER USER "www-data" WITH NOSUPERUSER;`

From a psql shell you will see the following tables created:
by using the command ```\dt ```

```
Schema |        Name         | Type  |  Owner
--------+---------------------+-------+----------
public | file                | table | www-data
public | file_alias_path     | table | www-data
public | form                | table | www-data
public | image               | table | www-data
public | optional            | table | www-data
public | param               | table | www-data
public | perm                | table | www-data
public | perm_category       | table | www-data
public | perm_class          | table | www-data
public | required            | table | www-data
public | schema              | table | www-data
public | session             | table | www-data
public | sticky              | table | www-data
public | user_perm           | table | www-data
public | users               | table | www-data
public | validation_messages | table | www-data
```
