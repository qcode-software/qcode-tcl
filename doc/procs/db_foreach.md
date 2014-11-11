qc::db_foreach
==============

part of [Database API](../qc/wiki/DatabaseApi)

Usage
-----
`qc::db_foreach args`

Description
-----------
Place variables corresponding to column names in the caller's namespace for each row returned.
    Set special variables db_nrows and db_row_number in caller's namespace to
    indicate the number of rows returned and the current row.
    Nested foreach statements clean up special variables so they apply to the current scope.

Examples
--------
```tcl

% set qry {select firstname,surname from users order by surname} 
% db_foreach $qry {
    lappend list "$surname, $firstname"
}

% set category Lights
% set qry {
    select product_code,description,price 
    from products 
    where category=:category 
    order by product_code
}
% db_foreach $qry {
    append html &lt;li&gt;$db_row_number $product_code $description $price&lt;/li&gt;
}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"