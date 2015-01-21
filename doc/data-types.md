Data Types: is, cast, castable
====================
part of [Qcode Documentation](index.md)

* * *

The library provides many useful procedures for determining if a string is a certain data type, whether it can be cast to a certain data type, and for actually casting to that data type.

There are 3 ensembles provided that cover many data types:

* [qc::is]
* [qc::cast]
* [qc::castable]

These ensembles are also able to handle aliases akin to some [PostgreSQL data types]. The list of aliases and the command they map to:

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


* * *

Qcode Software Limited <http://www.qcode.co.uk>

[qc::is]: is.md
[qc::cast]: cast.md
[qc::castable]:castable.md
[PostgreSQL data types]: http://www.postgresql.org/docs/9.4/static/datatype.html#DATATYPE-TABLE