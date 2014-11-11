qc::ldelete
===========

part of [Docs](../index.md)

Usage
-----
`
        qc::ldelete listVar index
    `

Description
-----------
Deletes item at $index of list

Examples
--------
```tcl

% set items [list "Mr" "Angus" "Jamison"]
Mr Angus Jamison
% qc::ldelete items 0
Angus Jamison
% set items
Angus Jamison
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"