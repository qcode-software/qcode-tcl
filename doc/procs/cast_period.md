qc::cast_period
===============

part of [Docs](.)

Usage
-----
`qc::cast_period string`

Description
-----------
Return a pair of dates defining the period.

Examples
--------
```tcl

% cast_period "2014-01-01"
2014-01-01 2014-01-01
%
% cast_period "Jan 1st 2014"
2014-01-01
%
% cast_period "2014"
2014-01-01 2014-12-31
%
% cast_period "Jan"
2014-01-01 2014-01-31
%
% cast_period "January"
2014-01-01 2014-01-31
%
% cast_period "Jan 2013"
2013-01-01 2013-01-31
%
% cast_period "January 2013"
2013-01-01 2013-01-31
%
% cast_period "January 2013 to March 2013"
2013-01-01 2013-03-31
%
% cast_period "1st Jan 2013 to 14th Jan 2013"
2013-01-01 2013-01-14
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"