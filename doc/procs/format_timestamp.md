qc::format_timestamp
====================

part of [Docs](../index.md)

Usage
-----
`qc::format_timestamp args`

Description
-----------
Format string as datetime for user.<br/>Will be customizable in future but at present chooses the ISO format.
Flag `-text` will return the result as text otherwise will return the result with html entities.

Examples
--------
```tcl

% format_timestamp -text now
2007-11-05 17:30:14

% format_timestamp now
2014&#8209;12&#8209;17 11:56:09

% format_timestamp -text "23/5/2008 10:11:28"
2008-05-23 10:11:28

% format_timestamp -text "23rd June 2008 10:11"
2008-06-23 10:11:00

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"