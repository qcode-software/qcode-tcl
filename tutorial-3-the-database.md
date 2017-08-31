Tutorial 3: The Database
========
part of [Qcode Documentation](index.md)

-----

### Introduction

In order to make full use of Qcode Tcl an underlying data structure is required, a list of data dependencies can be viewed [here](doc/data-model-dependencies.md).

-----
### Prerequisites

You should have previously installed a [Postgresql](doc/postgresql-setup.md) instance and set up the appropriate user permissions. You will also need to install postgres-contrib:

```
apt-get install postgresql-contrib-9.4
```

Before proceeding you will need to create a blank database called `test`.

Next, you will need to modify your naviserver config to link to postgresql as shown [here](doc/naviserver-config-postgres.md)

Note: Ensure this line is present `ns_param     nsdb                    ${homedir}/bin/nsdb.so`

Finally, you will also need to have set up a control port in your naviserver config.  Details can be found in the [full config file](doc/naviserver-config-full.md) or the [naviserver API documentation](https://naviserver.sourceforge.io/n/nscp/files/nscp.html)

## Creating the Data structure

Telnet to your control port. Type the following commands:

```
> package require qcode
> set conf { host localhost port 5432 dbname test user postgres password [postgres_password_here] }
> qc::db_connect {*}$conf
> qc::db_init
```

The final command should return a value of "1" indicating that the data structure has been successfully set up.

## Connecting from Tcl

We can add the following proc to our earlier work to check the database, which you will be able to do by visiting the db_check.html page.

```
register GET /db_check.html {} {
    #| Check that we are connected to the database
    qc::db_0or1row {SELECT user_id FROM users WHERE user_id='-1'} {
	return "Not correctly set up"
    } {
	return "Correctly set up, found anonymous user with ID $user_id"
    }
}
```
