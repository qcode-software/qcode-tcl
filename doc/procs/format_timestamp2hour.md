qc::format_timestamp2hour
=========================

part of [Docs](../index.md)

Usage
-----
`qc::format_timestamp2hour ?-text? ?-html? string`

Description
-----------
Format string as an ISO timestamp without seconds.
Flag `-text` will return the result as text otherwise will return the result with html entities.

Examples
--------
```tcl

% qc::format_timestamp2hour -text now
2014-12-17 12:19

% format_timestamp2hour now
2014&#8209;12&#8209;17 12:20

% qc::format_timestamp2hour -text "17th Dec 2014 12:19:23"
2014-12-17 12:19

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"