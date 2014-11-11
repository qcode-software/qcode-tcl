qc::db_cache_1row
=================

part of [Cached Database API](../db_cache.md)

Usage
-----
`qc::db_cache_1row args`

Description
-----------
Cached equivalent of <proc>db_1row</proc>. Select one row from the cached results or the database if the cache has expired. Place variables corresponding to column names in the caller's namespace Throw an error if the number of rows returned is not exactly one.
    <p>
    Time-to-live, if specified, is given in seconds.

Examples
--------
```tcl

# Cache the results of a query for 20 seconds
% db_cache_1row -ttl 20 {select order_date from sales_order where order order_number=123}
% set order_date
2007-01-23
% 

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"