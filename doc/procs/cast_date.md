qc::cast_date
=============

part of [Casting Procs](../qc/wiki/CastPage)

Usage
-----
`qc::cast_date string`

Description
-----------
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
% cast_date &quot;June 23rd&quot;
2007-06-23
%
% cast_date 16
% 2007-10-16
%
% cast_date &quot;23rd 2008 June&quot;
2008-06-23

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"