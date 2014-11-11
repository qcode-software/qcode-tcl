qc::sigfigs
===========

part of [Docs](.)

Usage
-----
`
        qc::sigfigs x n
    `

Description
-----------
Returns x to n significant figures

Examples
--------
```tcl

% qc::sigfigs 9192837465 2
9200000000
% qc::sigfigs 12 1
10
% qc::sigfigs 12 5
12.000
% qc::sigfigs 12.2222 3
12.2
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"