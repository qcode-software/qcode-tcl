qc::year_months
===============

part of [Date Handling](../qc/wiki/DateHandling)

Usage
-----
`qc::year_months from_date to_date`

Description
-----------
Returns list of iso year/iso month pairs between from_date & to_date

Examples
--------
```tcl

% year_months 2007-02-25 2008-03-05
% 2007 2 2007 3 2007 4 2007 5 2007 6 2007 7 2007 8 2007 9 2007 10 2007 11 2007 12 2008 1 2008 2 2008 3
% year_months 2007-02-25 2007-02-26
% 2007 2

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"