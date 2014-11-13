qc::format_timestamp_rel_age
============================

part of [Docs](../index.md)

Usage
-----
`qc::format_timestamp_rel_age args`

Description
-----------
Return the approximate relative age of a timestamp

Examples
--------
```tcl

% qc::format_timestamp_rel_age "2009-10-12 12:12:12"
5 years
% qc::format_timestamp_rel_age -long "2009-10-12 12:12:12"
5 years ago
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"