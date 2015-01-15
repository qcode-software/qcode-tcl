qc::is timestamp
==============

part of [Docs](../index.md)

Usage
-----
`qc::is timestamp string`

Description
-----------
Checks if the given string is a timestamp (in ISO format).

Examples
--------
```tcl

% qc::is timestamp "2015-01-15 17:15:33"
1
% qc::is timestamp "2015-01-15"
0
% qc::is timestamp foo
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"