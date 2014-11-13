qc::db_cache_ldict
==================

part of [Cached Database API](../db_cache.md)

Usage
-----
`qc::db_cache_ldict qry`

Description
-----------
Cached version of db_select_ldict.

Examples
--------
```tcl

% set qry {select firstname,surname from users}
% db_cache_ldict $qry
{firstname John surname Mackay} {firstname Andrew surname MacDonald} {firstname Angus surname McNeil}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"