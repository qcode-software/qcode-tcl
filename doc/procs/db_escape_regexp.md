qc::db_escape_regexp
====================

part of [Database API](../db.md)

Usage
-----
`db_escape_regexp string`

Description
-----------
Used to escape regular expression metacharacters.

Examples
--------
```tcl

% db_escape_regexp Finlay.son
% Finlay\.son

% db_escape_regexp "*fish"
% \*fish

% db_escape_regexp {C:\one\tow}
% C:\\one\\tow

% set email andrew.
% set qry "select * from customer where email ~* [db_quote "^[db_escape_regexp $email]"]"
select * from customer where email ~* '^andrew\.'

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"