qc::is bigint
==============

part of [Is API](../is.md)

Usage
-----
`qc::is bigint int`

Description
-----------
Checks if the given string is a big integer.
A bigint is an integer in the range of -9223372036854775808 to +9223372036854775807

Examples
--------
```tcl

% qc::is bigint -9223372036854775808
1
% qc::is bigint -9223372036854775809
0
% qc::is bigint foo
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"