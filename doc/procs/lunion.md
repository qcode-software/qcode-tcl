qc::lunion
==========

part of [Docs](../index.md)

Usage
-----
`
        qc::lunion list list
    `

Description
-----------
Return union of 2 lists

Examples
--------
```tcl

% set l1 [list 4 3 3 2 1]
4 3 3 2 1
% set l2 [list 1 3 5 7]
1 3 5 7
% qc::lunion $l1 $l2
1 2 3 4 5 7
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"