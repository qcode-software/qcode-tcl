Tutorial 6: Storing user input in the database
========
part of [Qcode Documentation](index.md)

-----

### Introduction

This tutorial will guide you through replacing our previously used naviserver variables with database storage and retrieval using `db_dml` and `db_1row`.

-----
## Database setup

Before we can store user input in the database, we need to set up a simple table, as follows:

```
CREATE TABLE people (
          person_id INT PRIMARY KEY,
          first_name VARCHAR(255),
          last_name VARCHAR(255)
          );
CREATE SEQUENCE person_id_seq;
```

This creates a table with three columns, two to store our user input and one to store an ID for retrieving that data. 

`CREATE SEQUENCE` is used to define a new sequence number generator for use as our ID.

-----
## Saving user input to the database

In order to store our `first_name` and `last_name` user input, we use the `db_dml` command.

Replace the body of our `register POST /form_process` proc with the following:

```
set person_id [db_seq person_id_seq]
db_dml "insert into people [sql_insert person_id first_name last_name]"

ns_returnredirect [qc::url form_results.html person_id $person_id]
```

[`db_seq person_id_seq`](procs/db_seq.md) increments and retrieves the next number in the sequence we created for use as an ID.

The [`db_dml`](procs/db_dml.md) command executes the insert query built using the [`sql_insert`](procs/sql_insert.md) proc.

The ID generated is then appended to our results URL as a structured string using the [`url`](procs/url.md) proc.

-----
## Retrieving our data

In the `register GET /form_results.html` proc, remove the two lines we currently use to retreive the `first_name` and `last_name` from naviserver variables and replace them with the following:

```
db_1row "SELECT first_name, last_name FROM people WHERE person_id = :person_id"
```
And add the variable as a arg
```
register GET /form_results.html { person_id }
```

The [`db_1row`](procs/db_1row.md) proc will return a single row from the database, placing variables corresponding to column names in the caller's namespace.

You can verify that the data is being stored correctly with a properly incrementing ID by entering a few names, then viewing the data in a psql shell using the following command:

```psql
select person_id, first_name, last_name from people;
```
