qc::castable period
==============

part of [Docs](../index.md)

Usage
-----
`qc::castable period string`

Description
-----------
Test if the given string can be cast to a period.

Examples
--------
```tcl

% qc::castable period "2014-01-01"
true

% qc::castable period "Jan 1st 2014"
true

% qc::castable period "2014"
true

% qc::castable period "Jan"
true

% qc::castable period "January"
true

% qc::castable period "Jan 2013"
true

% qc::castable period "January 2013"
true

% qc::castable period "January 2013 to March 2013"
true

% qc::castable period "1st Jan 2013 to 14th Jan 2013"
true
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"