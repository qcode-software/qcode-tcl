qc::date_year_iso_start
=======================

part of [Date Handling](../qc/wiki/DateHandling)

Usage
-----
`qc::date_year_iso_start date`

Description
-----------
Return the date on the 1st day of the ISO year for the date given.<br/>ISO Week numbers start on Monday.<br/>The first week of the year includes the first Thursday.<br/>The first week also includes the 4th Jan

Examples
--------
```tcl

% date_year_start 2006-05-06
% 2006-01-02
%
% date_year_start &quot;2 years ago&quot;
% 2005-01-03

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"