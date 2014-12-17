qc::format_timestamp_iso
========================

part of [Docs](../index.md)

Usage
-----
`qc::format_timestamp_iso args`

Description
-----------
Format string as an ISO timestamp.
Flag `-text` will return the result as text otherwise will return the result with html entities.

Examples
--------
```tcl

% format_timestamp_iso -text now
2007-11-05 17:30:14

% format_timestamp_iso now
2014&#8209;12&#8209;17 11:23:43

% format_timestamp_iso -text "23/5/2008 10:11:28"
2008-05-23 10:11:28
%
% format_timestamp_iso -text "23rd June 2008 10:11"
2008-06-23 10:11:00

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"