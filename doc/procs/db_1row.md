qc::db_1row
===========

part of [Database API](../db.md)

Usage
-----
`db_1row qry`

Description
-----------
Select one row from the database using the qry. Place variables corresponding to column names in the caller's namespace Throw an error if more or less than 1 row is returned.

Examples
--------
```tcl

% db_1row {select order_date from sales_order where order order_number=123}
% set order_date
2007-01-23
%
% set order_number 567545
% db_1row {select order_date from sales_order where order order_number=:order_number}
% set order_date
2006-02-05

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"