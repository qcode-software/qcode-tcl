qc::cast varchar
==============

part of [Docs](../index.md)

Usage
-----
`qc::cast varchar length string`

Description
-----------
Cast to varchar.

Examples
--------
```tcl

% qc::cast varchar 5 Hello
Hello
% qc::cast varchar 15 foo
foo
% qc::cast varchar 1 foo
Can't cast "foo" to varchar(1). String is too long.
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"