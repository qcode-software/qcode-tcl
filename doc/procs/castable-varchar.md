qc::castable varchar
==============

part of [Castable API](../castable.md)

Usage
-----
`qc::castable varchar length string`

Description
-----------
Test if the given string can be cast to varchar of the given length.

Examples
--------
```tcl

% qc::castable varchar 25 Hello
true
% qc::castable varchar 2 World
false
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"