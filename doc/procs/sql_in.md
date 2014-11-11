qc::sql_in
==========

part of [Docs](.)

Usage
-----
`qc::sql_in list ?type?`

Description
-----------
Return a SQL comma separated list

Examples
--------
```tcl

% qc::sql_in [list blue yellow orange]
('blue','yellow','orange')

% set qry "select * from users where surname in [qc::sql_in [list Campbell Graham Fraser]]"
select * from users where surname in ('Campbell','Graham','Fraser')

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"