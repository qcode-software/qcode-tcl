qc::is char
==============

part of [Is API](../is.md)

Usage
-----
`qc::is char length string`

Description
-----------
Checks if the given string would fit exactly into a character string of the given length.

Examples
--------
```tcl

% qc::is char 11 "Hello World"
1
% qc::is char 10 "Hello World"
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"