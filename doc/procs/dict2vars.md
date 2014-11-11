qc::dict2vars
=============

part of [Docs](.)

Usage
-----
`
	qc::dict2vars dict ?varName? ?varName? ...
    `

Description
-----------
Set all or a subset of the {key value} pairs in dict as variables in the caller.<br/><br/>If a list of keys is provided only set corresponding variables.<br/>If any of the keys do not exist in the dict unset the variable in the caller if it exists.

Examples
--------
```tcl

% set dict { a 1 b 2 c 3}
a 1 b 2 c 3
% set d 4
4

% qc::dict2vars $dict
% puts "a:$a, b:$b, c:$c, d:$d"
a:1, b:2, c:3, d:4

% qc::dict2vars $dict a b
% puts "a:$a, b:$b"
a:1, b:2

% qc::dict2vars $dict a b d
% puts "a:$a, b:$b, d:$d"
can't read "d": no such variable

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"