qc::lreplace_values
===================

part of [Docs](.)

Usage
-----
`
        qc::lreplace_values list find replace
    `

Description
-----------
Replace any occurrence of $find in $list with $replace

Examples
--------
```tcl

% set items [list 9.99 8.49 6.49 NULL 10.99 NULL 1.99]
9.99 8.49 6.49 NULL 10.99 NULL 1.99
% qc::lreplace_values $items NULL 0
9.99 8.49 6.49 0 10.99 0 1.99
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"