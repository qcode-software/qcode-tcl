qc::castable enumeration
==============

part of [Castable API](../castable.md)

Usage
-----
`qc::castable enumeration name value`

Description
-----------
Test if the given value can be cast to an enumeration value in $name.

Examples
--------
```tcl

% qc::castable enumeration post_state live
true
% qc::castable enumeration post_state foo
false
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"