qc::dict_exists
===============

part of [Docs](.)

Usage
-----
`
	qc::dict_exists dict ?key? ?key? ...
    `

Description
-----------
Return true if the given key (or path to key) exists.<br/>Otherwise return false.<br/>Unlike dict exists command, do not fail if path to key does not exist.<br/>Eg: dict_exists [dict create a 1 b 2 c 3] a a1

Examples
--------
```tcl

% set dict {a 1 b {b1 1 b2 2} c 3}
a 1 b {b1 1 b2 2} c 3

% qc::dict_exists $dict a
1

% qc::dict_exists $dict b b1
1

% qc::dict_exists $dict d
0

% qc::dict_exists $dict c d
0

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"