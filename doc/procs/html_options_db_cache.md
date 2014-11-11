qc::html_options_db_cache
=========================

part of [Docs](../index.md)

Usage
-----
`qc::html_options_db_cache qry ?ttl?`

Description
-----------
Expects a qry use columns named "name" and "value"<br/>Use aliases where required.<br/>E.g select foo_id as value,description as name from foo<br/>Query results are cached

Examples
--------
```tcl

% set qry {select country as name,country_code as value from countries order by country}
% qc::html_options_db_cache $qry
Afghanistan AF Albania AL Algeria DZ ..... Yemen YE Yugoslavia YU Zambia ZM Zimbabwe ZW

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"