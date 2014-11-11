qc::db_col_varchar_length
=========================

part of [Database API](../db.md)

Usage
-----
`qc::db_col_varchar_length table_name col_name`

Description
-----------
Returns the varchar length of a db table column

Examples
--------
```tcl

# A table sales_orders has column delivery_address1 type varchar(100)
% db_col_varchar_length sales_orders delivery_address1
100

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"