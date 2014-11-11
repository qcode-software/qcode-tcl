qc::db_select_csv
=================

part of [Database API](../qc/wiki/DatabaseApi)

Usage
-----
`qc::db_select_csv qry ?level?`

Description
-----------
Select the results of the SQL qry into a csv report. First row contains column names.Lines separated with windows \\r\\n

Examples
--------
```tcl

% db_select_csv {select user_id,firstname,surname from users}
user_id,firstname,surname
83214205,Angus,MacDonald
83214206,Iain,MacDonald
83214208,Donald,MacDonald

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"