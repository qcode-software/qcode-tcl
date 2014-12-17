qc::format_timestamptz
======================

part of [Docs](../index.md)

Usage
-----
`qc::format_timestamptz args`

Description
-----------
Format string as an ISO timestamp with time zone.
Flag `-text` will return the result as text otherwise will return the result with html entities.

Examples
--------
```tcl

% format_timestamptz -text "2 days ago"
2014-12-15 00:00:00 +0000

% format_timestamptz "2 days ago"
2014&#8209;12&#8209;15 00:00:00 +0000

% format_timestamptz -text "17th Dec 2014 11:25"
2014-12-17 11:25:00 +0000

% format_timestamptz -text "17/12/14 11:25:35"
2014-12-17 11:25:35 +0000

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"