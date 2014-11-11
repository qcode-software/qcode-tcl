qc::db_cache_0or1row
====================

part of [Cached Database API](../)

Usage
-----
`qc::db_cache_0or1row args`

Description
-----------
Cached equivalent of <proc>db_0or1row</proc>.<br>
    Select zero or one row from the cached results or the database if the cache has expired. Place variables corresponding to column names in the caller's namespace.<br>
    If zero rows are returned then run no_rows_code else place variables corresponding to column names in the caller's namespace and execute one_row_body.
    <p>
    Time-to-live, if specified, is given in seconds.

Examples
--------
```tcl

# Cache results for 20 seconds.
% db_cache_0or1row -ttl 20 {select order_date from sales_orders where order order_number=123} {
    puts &quot;No Rows Found&quot;
} {
    puts &quot;Order Date $order_date&quot;
}
No Rows Found

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"