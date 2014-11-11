qc::schema_update
=================

part of [Docs](.)

Usage
-----
`qc::schema_update version code`

Description
-----------
Run the code if it applies to the current schema in order to bring the schema up to the next version.

Examples
--------
```tcl

schema_update 19 {
    db_dml { alter table product add column ean bigint }
}


```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"