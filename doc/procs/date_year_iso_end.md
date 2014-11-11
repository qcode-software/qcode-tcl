qc::date_year_iso_end
=====================

part of [Date Handling](../date.md)

Usage
-----
`qc::date_year_iso_end date`

Description
-----------
Return the date on the last day of the ISO year for the date given.<br/>ISO Week numbers start on Monday<br/>The first week of the year includes the first Thursday

Examples
--------
```tcl

% date_year_iso_end 2007-05-06
% 2007-12-30
%
% date_year_iso_end "last year"
% 2006-12-31

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"