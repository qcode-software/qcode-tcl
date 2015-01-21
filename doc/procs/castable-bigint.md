qc::castable bigint
==============

part of [Docs](../index.md)

Usage
-----
`qc::castable bigint string`

Description
-----------
Test if the given string can be cast to a bigint.

A big int is an integer in the range of -9223372036854775808 to +9223372036854775807

Examples
--------
```tcl

% qc::castable bigint {1,234}
true
% qc::castable bigint foo
false
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"