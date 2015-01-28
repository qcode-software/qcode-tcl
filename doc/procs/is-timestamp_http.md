qc::is timestamp_http
=====================

part of [Docs](../index.md)

Usage
-----
`qc::is timestamp_http date`

Description
-----------
Check if the given date is an acceptable HTTP timestamp.

Note although all three should be accepted, only RFC 1123 format should be generated.

Examples
--------
```tcl
# RFC 1123
% qc::is timestamp_http "Sun, 06 Nov 1994 08:49:37 GMT"
1

# RFC 850
% qc::is timestamp_http Sunday, 06-Nov-94 08:49:37 GMT""
1

# ANCI C
% qc::is timestamp_http "Sun Nov  6 08:49:37 1994"
1

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"