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

% cast_period &quot;2014-01-01&quot;
2014-01-01 2014-01-01
%
% cast_period &quot;Jan 1st 2014&quot;
2014-01-01
%
% cast_period &quot;2014&quot;
2014-01-01 2014-12-31
%
% cast_period &quot;Jan&quot;
2014-01-01 2014-01-31
%
% cast_period &quot;January&quot;
2014-01-01 2014-01-31
%
% cast_period &quot;Jan 2013&quot;
2013-01-01 2013-01-31
%
% cast_period &quot;January 2013&quot;
2013-01-01 2013-01-31
%
% cast_period &quot;January 2013 to March 2013&quot;
2013-01-01 2013-03-31
%
% cast_period &quot;1st Jan 2013 to 14th Jan 2013&quot;
2013-01-01 2013-01-14
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"