qc::is hex
==========

part of [Docs](../index.md)

Usage
-----
`qc::is hex string`

Description
-----------
Checks if the given string is a hex number.

Examples
--------
```tcl

%  qc::is hex 9F
1
%  qc::is hex 1a
1
%  qc::is hex 9G
0
% qc::is hex 9FFFFFF
1
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
