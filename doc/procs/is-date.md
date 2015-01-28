qc::is date
==============

part of [Is API](../is.md)

Usage
-----
`qc::is date string`

Description
-----------
Checks if the given string is a date.
Dates are expected to be in ISO format: YYYY-MM-DD

Examples
--------
```tcl

% qc::is date 2015-01-16
1
% qc::is date 01-01-2015
0
% qc::is date "text"
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"