qc::db_escape_regexp
====================

part of [Database API](../qc/wiki/DatabaseApi)

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

% db_escape_regexp &quot;*fish&quot;
% \*fish

% db_escape_regexp {C:\one\tow}
% C:\\one\\tow

% set email andrew.
% set qry &quot;select * from customer where email ~* [db_quote &quot;^[db_escape_regexp $email]&quot;]&quot;
select * from customer where email ~* &#39;^andrew\.&#39;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"