qc::db_canonical_type
===========

part of [Database API](../db.md)

Usage
-----
`db_canonical_type udt_name ?character_maximum_length? ?numeric_precision? ?numeric_scale?`

Description
-----------
Returns the canonical type name for the given type name.

Examples
--------
```tcl

% db_canonical_type varchar 60
varchar(60)

% db_canonical_type numeric "" 5 3
decimal(5, 3)

% db_canonical_type bpchar 25
char(25)


```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"