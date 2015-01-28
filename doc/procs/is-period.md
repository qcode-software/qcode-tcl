qc::is period
=============

part of [Is API](../is.md)

Usage
-----
`qc::is period string`

Description
-----------
Check if the given string can represent a period of time.

Examples
--------
```tcl
% qc::is period "2014-01-01"
1
% qc::is period "Jan 1st 2014"
1
% qc::is period "2014"
1
% qc::is period "Jan"
1
% qc::is period "January"
1
% qc::is period "Jan 2013"
1
% qc::is period "January 2013"
1
% qc::is period "January 2013 to March 2013"
1
& qc::is period "Jan2013"
0
% qc::is period "January 2013 March 2013"
0
% qc::is period "1st Jan 2013 to 14th Jan 2013"
1
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
