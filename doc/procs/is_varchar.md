qc::is_varchar
==============

part of [Docs](../index.md)

Usage
-----
`qc::is_varchar string length`

Description
-----------
Deprecated - see [qc::is varchar]
Checks string would fit in a varchar of length $length

Examples
--------
```tcl

% qc::is_varchar "Too long string" 14
0
% qc::is_varchar "Small Enough" 14
1
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[qc::is varchar]: is-varchar.md