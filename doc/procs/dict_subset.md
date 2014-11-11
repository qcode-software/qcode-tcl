qc::dict_subset
===============

part of [Docs](.)

Usage
-----
`
	qc::dict_subset dict ?key? ?key? ...
    `

Description
-----------
Return a dict made up of the keys given.

Examples
--------
```tcl

% set dict {a 1 b {b1 1 b2 2} c 3}
a 1 b {b1 1 b2 2} c 3

% qc::dict_subset $dict a
a 1

% qc::dict_subset $dict b c
b {b1 1 b2 2} c 3

% qc::dict_subset $dict c d
c 3

% qc::dict_subset $dict d
 

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"