qc::sql_where
=============

part of [Database API](../qc/wiki/DatabaseApi)

Usage
-----
`sql_where varName1 ?varName2 varName3 ...?`

Description
-----------
Construct a SQL <i>WHERE</i> clause based on local TCL variables.<br>
    Don't use the variable if it does not exist or its value is the empty string.<br>
    Return <code>true</code> if all variables are empty or non-existent.

Examples
--------
```tcl

% set email jimmy@tarbuck.com
% sql_where email
email=&#39;jimmy@tarbuck.com&#39;
% 
% set name Jimmy
% set qry &quot;select * from users where [sql_where name $name email $email]&quot;
select * from users where name=&#39;Jimmy&#39; and email=&#39;jimmy@tarbuck.com&#39;
%
% set product_code &quot;&quot;
set qry &quot;select * from products where [sql_where product_code $product_code category $category] LIMIT 100&quot;
select * from products where true LIMIT 100

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"