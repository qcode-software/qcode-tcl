qc::lconcat
===========

part of [Docs](.)

Usage
-----
`
        qc::lconcat listVar list
    `

Description
-----------
Concatenate list onto supplied listVar

Examples
--------
```tcl

% set l1 [list 4 3 3 2 1]
4 3 3 2 1
% set l2 [list 1 3 5 7]
1 3 5 7
% qc::lconcat l1 $l2
4 3 3 2 1 1 3 5 7
% set l1
4 3 3 2 1 1 3 5 7
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"