Data Types: is, cast, castable
====================
part of [Qcode Documentation](index.md)

* * *

The library provides many useful procedures for determining if a string is a certain data type, whether it can be cast to a certain data type, and for casting to that data type.

There are 3 ensembles provided that cover many data types:

* [qc::is]
* [qc::cast]
* [qc::castable]

These ensembles are also able to handle aliases akin to some [PostgreSQL data types].

Supported aliases and equivalent commands:

```
varchar(x) arg   > varchar x arg
char(x) arg      > char x arg
decimal(x,y) arg > decimal -precision x -scale y arg
decimal(x) arg   > decimal -precision x arg
numeric(x,y) arg > decimal -precision x -scale y arg
numeric(x) arg   > decimal -prevision x arg
numeric arg      > decimal arg
bool arg         > boolean arg
int arg          > integer arg
int4 arg         > integer arg
int2 arg         > smallint arg
int8 arg         > bigint arg
```

### Examples

```Tcl

% qc::is varchar(20) "Foo"
1

% qc::is varchar 20 "Foo"
1

% qc::cast numeric(3,2) 3.14159
3.14

% qc::cast numeric -precision 3 -scale 2 3.14159
3.14

% qc::cast int2 35000
Could not cast 35000 to smallint.

```

Domains & Enumerated Types
----------------------

All three ensembles also support [domains] and [enumerations] as first-class data types which makes dealing with them a lot easier.

For example; given a domain in the database called `plain_text` defined as:

```SQL
CREATE DOMAIN plain_text AS TEXT
CHECK(
   VALUE !~ '<([^>]+)>'
);
```

We can use the domain as a first-class data type:

```Tcl

% qc::is plain_text "Foo"
1

% qc::is plain_text {<foo>Bar</foo>}
0

% qc::cast plain_text {<foo>Bar</foo>}
Can't cast "<foo>Bar</foo>...": not a valid value for "plain_text".

% qc::castable plain_text "Hello World"
true

```

The same idea applies to enumerated types:

```SQL
CREATE TYPE user_state AS ENUM ('ACTIVE', 'DISABLED');
```

```Tcl

% qc::is user_state active
0

% qc::is user_state ACTIVE
1

% qc::cast user_state active
ACTIVE

% qc::castable user_state foo
false

```

* * *

Qcode Software Limited <http://www.qcode.co.uk>

[qc::is]: is.md
[qc::cast]: cast.md
[qc::castable]:castable.md
[PostgreSQL data types]: http://www.postgresql.org/docs/9.4/static/datatype.html#DATATYPE-TABLE
[domains]: http://www.postgresql.org/docs/9.4/static/sql-createdomain.html
[enumerations]: http://www.postgresql.org/docs/9.4/static/datatype-enum.html