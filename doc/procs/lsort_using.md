qc::lsort_using
===============

part of [Docs](../index.md)

Usage
-----
`
        qc::lsort_using list order
    `

Description
-----------
Apply an arbitrary sort order to a list

Examples
--------
```tcl

% set items [list R W E Q]
R W E Q
% qc::lsort_using $items {Q W E R T Y}
Q W E R
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"