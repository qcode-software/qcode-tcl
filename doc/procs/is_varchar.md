qc::is_varchar
==============

part of [Docs](.)

Usage
-----
`qc::is_varchar string length`

Description
-----------
Checks string would fit in a varchar of length $length

Examples
--------
```tcl

% qc::is_varchar &quot;Too long string&quot; 14
0
% qc::is_varchar &quot;Small Enough&quot; 14
1
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"