qc::ldelete
===========

part of [Docs](.)

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

% set items [list &quot;Mr&quot; &quot;Angus&quot; &quot;Jamison&quot;]
Mr Angus Jamison
% qc::ldelete items 0
Angus Jamison
% set items
Angus Jamison
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"