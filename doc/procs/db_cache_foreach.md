qc::db_cache_foreach
====================

part of [Cached Database API](../)

Usage
-----
`qc::db_cache_foreach args`

Description
-----------
Cached equivalent of <proc>db_foreach</proc>.<br> 
    Use cached results or the database if the cache has expired.
    Place variables corresponding to column names in the caller's namespace for each row returned.
    Set special variables db_nrows and db_row_number in caller's namespace to
    indicate the number of rows returned and the current row.<br>
    Time-to-live, if specified, is given in seconds.

Examples
--------
```tcl

% set qry {select firstname,surname from users order by surname} 
% db_cache_foreach -ttl 20 $qry {
    lappend list &quot;$surname, $firstname&quot;
}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"