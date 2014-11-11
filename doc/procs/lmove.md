qc::lmove
=========

part of [Docs](.)

Usage
-----
`
        qc::lmove list from_index to_index
    `

Description
-----------
Move an element in a list from one place to another

Examples
--------
```tcl

% set items [list a b d c e]
a b d c e
% qc::lmove $items 2 3
a b c d e
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"