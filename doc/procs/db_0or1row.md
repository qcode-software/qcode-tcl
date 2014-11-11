qc::db_0or1row
==============

part of [Database API](../qc/wiki/DatabaseApi)

Usage
-----
`db_0or1row qry ?no_rows_code? ?one_row_code?`

Description
-----------
Select zero or one row from the database using the qry.
    If zero rows are returned then run no_rows_code else 
    place variables corresponding to column names in the caller's namespace and execute one_row_body

Examples
--------
```tcl

% db_0or1row {select order_date from sales_orders where order order_number=123} {
    puts &quot;No Rows Found&quot;
} {
    puts &quot;Order Date $order_date&quot;
}
No Rows Found
%
set order_number 654456
db_0or1row {select order_date from sales_orders where order order_number=:order_number} {
    puts &quot;No Rows Found&quot;
} {
    puts &quot;Order Date $order_date&quot;
}
Order Date 2007-06-04

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"