qc::date_compare
================

part of [Date Handling](../date.md)

Usage
-----
`qc::date_compare date1 date2`

Description
-----------
Compare 2 date expressions and return 1,0,-1 if date1 is greater,equal or less than date2

Examples
--------
```tcl

% date_compare 2007-08-06 2007-08-07
% -1
%
% date_compare 2007-08-06 2007-08-06
% 0
%
% date_compare 2007-08-06 2007-08-05
% 1

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"