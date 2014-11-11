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

% is_period &quot;2014-01-01&quot;
true
%
% is_period &quot;Jan 1st 2014&quot;
true
%
% is_period &quot;2014&quot;
true
%
% is_period &quot;Jan&quot;
true
%
% is_period &quot;January&quot;
true
%
% is_period &quot;Jan 2013&quot;
true
%
% is_period &quot;January 2013&quot;
true
%
% is_period &quot;January 2013 to March 2013&quot;
true
%
&amp; is_period &quot;Jan2013&quot;
false
%
% is_period &quot;January 2013 March 2013&quot;
false        
%
% is_period &quot;1st Jan 2013 to 14th Jan 2013&quot;
true
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"