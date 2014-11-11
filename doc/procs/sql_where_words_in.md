qc::sql_where_words_in
======================

part of [Database API](../qc/wiki/DatabaseApi)

Usage
-----
`sql_where_words_in name phrase`

Description
-----------
Construct part of a SQL WHERE clause to find a word in a string

Examples
--------
```tcl

% set name &quot;Jimmy Carr&quot;
% set qry &quot;select * from users where [sql_where_words_in name $name]&quot;
select * from users where name ~ &#39;( |^)Jimmy( |$)&#39; and name ~ &#39;( |^)Carr( |$)&#39;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"