qc::cast_date
=============

part of [Casting Procs](../cast.md)

Usage
-----
`qc::cast_date string`

Description
-----------
Deperecated - see [qc::cast date]
Try to convert the given string into an ISO date.

Examples
--------
```tcl

% cast_date 12/5/07
2007-05-12
# At present dates in this format are assumed to be European DD/MM/YY
%
% cast_date yesterday
2007-05-11
%
% cast_date "June 23rd"
2007-06-23
%
% cast_date 16
% 2007-10-16
%
% cast_date "23rd 2008 June"
2008-06-23

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[qc::cast date]: cast-date.md