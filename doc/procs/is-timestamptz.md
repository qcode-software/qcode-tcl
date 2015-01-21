qc::is timestamptz
==============

part of [Docs](../index.md)

Usage
-----
`qc::is timestamptz string`

Description
-----------
Checks if the given string is a timestamp with a time zone (in ISO format).

Examples
--------
```tcl

% qc::is timestamptz "2015-01-15 17:15:33+01"
1
% qc::is timestamptz "2015-01-15"
0
% qc::is timestamptz foo
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"