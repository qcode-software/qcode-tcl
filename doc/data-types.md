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

* varchar(x) string   > varchar x string
* char(x) string      > char x string
* decimal(x,y) string > decimal -precision x -scale y string
* decimal(x) string   > decimal -precision x string
* numeric(x,y) string > decimal -precision x -scale y string
* numeric(x) string   > decimal -prevision x string
* numeric string      > decimal string
* 
* 
* 
* 
* 


* * *

Qcode Software Limited <http://www.qcode.co.uk>

[qc::is]: is.md
[qc::cast]: cast.md
[qc::castable]:castable.md
[PostgreSQL data types]: http://www.postgresql.org/docs/9.4/static/datatype.html#DATATYPE-TABLE