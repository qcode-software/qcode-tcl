qc::sigfigs_ceil
================

part of [Docs](.)

Usage
-----
`
        qc::sigfigs_ceil x n
    `

Description
-----------
Returns x to n significant figures rounding up

Examples
--------
```tcl

% qc::sigfigs_ceil 9192837465 2
9200000000
% qc::sigfigs_ceil 12 1
20
% qc::sigfigs_ceil 12 5
12.000
% qc::sigfigs_ceil 12.2222 3
12.3
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"