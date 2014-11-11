qc::lunique
===========

part of [Docs](.)

Usage
-----
`
        qc::lunique list
    `

Description
-----------
Returns a list of distinct list values

Examples
--------
```tcl

% set items [list 1 1 1 2 2 3 4 5 5 6 6 6 6]
1 1 1 2 2 3 4 5 5 6 6 6 6
% qc::lunique $items
1 2 3 4 5 6
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"