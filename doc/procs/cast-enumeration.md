qc::cast enumeration
==============

part of [Docs](../index.md)

Usage
-----
`qc::cast enumeration name value`

Description
-----------
Cast $value to enumeration of $name.

Examples
--------
```tcl

% qc::cast enumeration post_state live
LIVE
% qc::cast enumeration foo bar
Can't cast "BAR": not a valid value for enumeration "foo".
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"