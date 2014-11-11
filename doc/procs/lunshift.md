qc::lunshift
============

part of [Docs](../index.md)

Usage
-----
`
        qc::lunshift listVar value
    `

Description
-----------
Adds $value as leftmost item in the list

Examples
--------
```tcl

% set items [list a b c d]
a b c d
% qc::lunshift items z
z a b c d
% set items
z a b c d
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"