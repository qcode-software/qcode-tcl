qc::is integer
==============

part of [Is API](../is.md)

Usage
-----
`qc::is integer int`

Description
-----------
Checks if the given string is an integer.

Examples
--------
```tcl

% qc::is integer 999
1
% qc::is integer 0.1
0
% qc::is integer 0
1
% qc::is integer true
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"