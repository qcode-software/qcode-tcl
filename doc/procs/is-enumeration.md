qc::is enumeration
==============

part of [Is API](../is.md)

Usage
-----
`qc::is enumeration enum_name value`

Description
-----------
Checks if the given value is belongs to the given enumeration in the database.

Examples
--------
```tcl

% qc::is enumeration post_state LIVE
1
% qc::is enumeration foo bar
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"