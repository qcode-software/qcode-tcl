qc::year_quarters
=================

part of [Date Handling](../qc/wiki/DateHandling)

Usage
-----
`qc::year_quarters from_date to_date`

Description
-----------
Returns list of iso year/quarter pairs between from_date & to_date

Examples
--------
```tcl

% year_quarters 2007-02-25 2008-03-05
% 2007 1 2007 2 2007 3 2007 4 2008 1
% year_quarters 2007-02-25 2007-02-26
% 2007 1

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"