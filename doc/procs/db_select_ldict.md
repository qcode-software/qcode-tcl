qc::db_select_ldict
===================

part of [Database API](../qc/wiki/DatabaseApi)

Usage
-----
`qc::db_select_ldict qry`

Description
-----------
Select the results of the SQL qry into a ldict. An ldict is a list of dicts

Examples
--------
```tcl

% set qry {select firstname,surname from users}
% db_select_ldict $qry
{firstname John surname Mackay} {firstname Andrew surname MacDonald} {firstname Angus surname McNeil}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"