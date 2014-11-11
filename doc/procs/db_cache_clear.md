qc::db_cache_clear
==================

part of [Cached Database API](../)

Usage
-----
`qc::db_cache_clear ?qry?`

Description
-----------
Delete the results from the database cache for the query given. If no query is specified then remove all time limited cached results.

Examples
--------
```tcl

# Delete the cache results for this query
% db_cache_clear {select order_date from sales_order where order order_number=123}

# Clear the entire cache
% db_cache_clear

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"