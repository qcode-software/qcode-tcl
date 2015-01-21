qc::is timestamp_http
==============

part of [Docs](../index.md)

Usage
-----
`qc::is timestamp_http date`

Description
-----------
Checks if the given date is an acceptable HTTP timestamp.
Accepts RFC 1123, RFC 850, and ANCI C date formats.

Examples
--------
```tcl

% qc::is timestamp_http {Fri, 16 Jan 2015 09:35:37 GMT}
1
% qc::is timestamp_http {Friday, 16-Jan-15 09:35:37 GMT}
1
% qc::is timestamp_http {Fri Jan  6 09:35:37 2015}
1
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"