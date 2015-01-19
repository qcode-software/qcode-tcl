qc::cast char
==============

part of [Docs](../index.md)

Usage
-----
`qc::cast char length string`

Description
-----------
Cast to char.

Examples
--------
```tcl

% qc::cast char 5 Hello
Hello
% qc::cast char 3 foo
foo
% qc::cast char 5 foo
Can't cast "foo" to char(5) data type.
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"