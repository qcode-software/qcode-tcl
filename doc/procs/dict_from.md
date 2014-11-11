qc::dict_from
=============

part of [Docs](.)

Usage
-----
`
	qc::dict_from ?varName? ?varName? ...
    `

Description
-----------
Take a list of var names and return a dict.

Examples
--------
```tcl

% set a 1; set b 2; set c 3

% qc::dict_from a b
a 1 b 2 

% qc::dict_from c d
Can't create dict with d: No such variable

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"