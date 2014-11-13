qc::db_select_table
===================

part of [Database API](../db.md)

Usage
-----
`qc::db_select_table args`

Description
-----------
Select the results of the query into a <proc>table</proc>. Substitute and quote bind variables starting with a colon.

Examples
--------
```tcl

% db_select_table {select user_id,firstname,surname from users}
% {user_id firstname surname} {73214205 Jimmy Tarbuck} {73214206 Des O'Conner} {73214208 Bob Monkhouse}

% set surname MacDonald
% db_select_table {select id,firstname,surname from users where surname=:surname}
% {user_id firstname surname} {83214205 Angus MacDonald} {83214206 Iain MacDonald} {83214208 Donald MacDonald}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"