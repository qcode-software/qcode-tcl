qc::format_date_rel
===================

part of [Date Handling](../date.md)

Usage
-----
`qc::format_date_rel date`

Description
-----------
Format the date relatively depending on age<br/>dates this month -> Wed 3rd<br/>dates this year -> JUN 3rd

Examples
--------
```tcl

% format_date_rel now
Today
% 
% format_date_rel tomorrow
Thu 18th
%
% format_date_rel "next month"
NOV 17th
%
% format_date_rel "next year"
2008-10-17

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"