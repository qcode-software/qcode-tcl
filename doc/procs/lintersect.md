qc::lintersect
==============

part of [Docs](.)

Usage
-----
`
        qc::lintersect list list
    `

Description
-----------
Returns the intersection of 2 lists

Examples
--------
```tcl

% set list1 [list a b c d e]
a b c d e
% set list2 [list d e f g h]
d e f g h
% qc::lintersect $list1 $list2
d e
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"