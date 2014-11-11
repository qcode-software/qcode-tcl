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
% &#39;0800&#39;

% db_quote MacKay
% &#39;MacKay&#39;

% db_quote O&#39;Neil
% &#39;O&#39;&#39;Neil&#39;

% db_quote &quot;&quot;
% NULL

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"