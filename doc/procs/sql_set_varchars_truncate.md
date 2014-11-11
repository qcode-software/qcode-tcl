qc::sql_set_varchars_truncate
=============================

part of [Database API](../qc/wiki/DatabaseApi)

Usage
-----
`sql_set_varchars_truncate table_name ?varName1 varName2 varName3 ...?`

Description
-----------
Take a list of varNames to be updated into varchar columns, and will construct a SQL set statement which will cast the values into the appropriate column's varchar size (effectively truncating the data if too long for the column).
        Useful when the data is being supplied by a third party who's data model may not match the table's.

Examples
--------
```tcl

% sql_set_varchars_truncate orders delivery_name delivery_address1
delivery_name=:delivery_name::varchar(50),delivery_address1=:delivery_address1::varchar(100)

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"