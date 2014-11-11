qc::is_period
=============

part of [Docs](.)

Usage
-----
`qc::is_period string`

Description
-----------
Test if string can be casted to a pair of dates defining a period.

Examples
--------
```tcl

% is_period "2014-01-01"
true
%
% is_period "Jan 1st 2014"
true
%
% is_period "2014"
true
%
% is_period "Jan"
true
%
% is_period "January"
true
%
% is_period "Jan 2013"
true
%
% is_period "January 2013"
true
%
% is_period "January 2013 to March 2013"
true
%
& is_period "Jan2013"
false
%
% is_period "January 2013 March 2013"
false        
%
% is_period "1st Jan 2013 to 14th Jan 2013"
true
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"