qc::format_timestamp_iso
========================

part of [Docs](../index.md)

Usage
-----
`qc::format_timestamp_iso string`

Description
-----------
Format string as an ISO timestamp

Examples
--------
```tcl

% format_timestamp_iso now
2007-11-05 17:30:14
%
% format_timestamp_iso "23/5/2008 10:11:28"
2008-05-23 10:11:28
%
% format_timestamp_iso "23rd June 2008 10:11"
2008-06-23 10:11:00

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"