qc::..
======

part of [Docs](.)

Usage
-----
`
        qc::.. from to ?step? ?limit?
    `

Description
-----------
List all values from $from to $to. Will attempt to guess the input type.
        The limit argument only affects alphabetic lists eg. Mon-Fri Jan-Feb

Examples
--------
```tcl

% qc::.. 1 10
1 2 3 4 5 6 7 8 9 10
% qc::.. 1 10 2
1 3 5 7 9
% qc::.. Mon Fri
Mon Tue Wed Thu Fri
% qc::.. MON FRI
MON TUE WED THU FRI
% qc::.. jan dec 1 6
jan feb mar apr may jun
% qc::.. 2012-06-04 2012-07-01
2012-06-04 2012-06-05 2012-06-06 2012-06-07 2012-06-08 2012-06-09 2012-06-10 2012-06-11 2012-06-12 2012-06-13 2012-06-14 2012-06-15 2012-06-16 2012-06-17 2012-06-18 2012-06-19 2012-06-20 2012-06-21 2012-06-22 2012-06-23 2012-06-24 2012-06-25 2012-06-26 2012-06-27 2012-06-28 2012-06-29 2012-06-30 2012-07-01
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"