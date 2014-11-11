qc::html_options_db
===================

part of [Docs](.)

Usage
-----
`qc::html_options_db qry`

Description
-----------
Expects a qry use columns named "name" and "value"<br/>Use aliases where required.<br/>E.g select foo_id as value,description as name from foo

Examples
--------
```tcl

% set qry {select country as name,country_code as value from countries order by country}
% qc::html_options_db $qry
Afghanistan AF Albania AL Algeria DZ ..... Yemen YE Yugoslavia YU Zambia ZM Zimbabwe ZW

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"