qc::cast date
=============

part of [Cast API](../cast.md)

Usage
-----
`qc::cast date string`

Description
-----------
Try to convert the given string into an ISO date.

Examples
--------
```tcl

% qc::cast date 12/5/07
2007-05-12

% qc::cast date yesterday
2015-01-15

% qc::cast date "June 23rd"
2015-06-23

% qc::cast date 16
2015-01-16

% qc::cast date "23rd 2008 June"
2008-06-23

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"