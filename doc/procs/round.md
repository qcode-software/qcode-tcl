qc::round
=========

part of [Docs](../index.md)

Usage
-----
`
        qc::round value dec_places
    `

Description
-----------
Perform rounding of $value to $dec_places places.
        Handles exponentials.
        Rounds up on 5
        e.g. 2.345 -> 2.35

Examples
--------
```tcl

% qc::round 1.23456789e5 2
123456.79
% qc::round 6 10
6.0000000000
% qc::round 6.66 8
6.66000000
% qc::round 0008.2345 3
8.235
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"