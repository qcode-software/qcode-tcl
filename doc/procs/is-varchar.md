qc::is varchar
==============

part of [Docs](../index.md)

Usage
-----
`qc::is varchar length string`

Description
-----------
Checks if the given string fits the given length. 

Examples
--------
```tcl

% qc::is varchar 10 hello
1
% qc::is varchar 2 foo
0
% qc::is varchar "" "Empty length specified means any length is allowed."
1
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"