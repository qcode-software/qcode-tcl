qc::dict_exclude
================

part of [Docs](.)

Usage
-----
`
	qc::dict_exclude dict ?key? ?key? ...
    `

Description
-----------
Return an dict excluding the keys given.

Examples
--------
```tcl

% set dict {a 1 b {b1 1 b2 2} c 3}
a 1 b {b1 1 b2 2} c 3

% qc::dict_exclude $dict a
b {b1 1 b2 2} c 3

% qc::dict_exclude $dict b c
a 1

% qc::dict_exclude $dict c d
a 1 b {b1 1 b2 2}

% qc::dict_exclude $dict d
a 1 b {b1 1 b2 2} c 3

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"