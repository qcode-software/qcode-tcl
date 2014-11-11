qc::db_quote
============

part of [Database API](../qc/wiki/DatabaseApi)

Usage
-----
`qc::db_quote value ?type?`

Description
-----------
Escape strings that contain single quotes e.g. O'Neil becomes 'O''Neil' Empty strings are replaced with NULL. Numbers are left unchanged.

Examples
--------
```tcl

% db_quote 23
% 23

% db_quote 0800
% '0800'

% db_quote MacKay
% 'MacKay'

% db_quote O'Neil
% 'O''Neil'

% db_quote ""
% NULL

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"