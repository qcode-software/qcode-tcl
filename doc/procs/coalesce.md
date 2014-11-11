qc::coalesce
============

part of [Docs](.)

Usage
-----
`qc::coalesce varName altValue`

Description
-----------
If varName exists then return its value<br/>else return the altvalue

Examples
--------
```tcl

% set foo 23
% coalesce foo 13
23
% coalesce bar 13
13

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"