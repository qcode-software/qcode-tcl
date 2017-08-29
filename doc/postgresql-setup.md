### Postgresql Setup

To install and prepare Postgresql on your dev environment run the following:

```
apt-get install postgresql
```

Once Postgresql is installed, you could start adding databases and running statements straight away, but it's better to set yourself up as a user before doing anything else rather than just use the default user account the Postgresql creates. 

In order to create a user in Postgresql, first you should log in as the postgres user:

```
sudo su - postgres
```

We can then start using the `psql` utility to view the users in the system and add our own.  Simply type `psql` and hit enter to start using the administrative interface, then you can use the command `\du` to list out the users. We should see the following information:

```
 Role name |                   Attributes                   | Member of 
-----------+------------------------------------------------+-----------
 postgres  | Superuser, Create role, Create DB, Replication | {}
```

It's not a good idea to use expose the postgres role as it's a superuser and can be used to do anything, including deleting entire databases. 

To create a new user you can use the `CREATE ROLE` command. You can then add permissions to this role using `ALTER ROLE` although to set up a basic web user, standard permissions are sufficient. 

The following syntax can be used to set up a new user called `"web"` with the password `"pass123"`:

```
CREATE ROLE web WITH LOGIN PASSWORD 'pass123';
```

Running `\du` again at this point would show us the new user has been added successfully:

```
 Role name |                   Attributes                   | Member of 
-----------+------------------------------------------------+-----------
 postgres  | Superuser, Create role, Create DB, Replication | {}
 web       |                                                | {}
```

Next up, we need to create a database to use:

```
CREATE DATABASE mydb;
```

Then we need to give our new web user permission to access the new database:

```
GRANT ALL PRIVILEGES ON DATABASE mydb TO web;
```

We should now be able to log on using the credentials we declared above and access the mydb database we just created.
