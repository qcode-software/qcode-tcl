qc::is_date_castable
====================

part of [Docs](.)

Usage
-----
`qc::is_date_castable string`

Description
-----------
Can string be cast into date format?

Examples
--------
```tcl

% qc::is_date_castable 10
true
% qc::is_date_castable "June 22nd"
true
% qc::is_date_castable tomorrow
true
% qc::is_date_castable May
false
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"