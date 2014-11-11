qc::format_timestamp
====================

part of [Docs](.)

Usage
-----
`qc::format_timestamp string`

Description
-----------
Format string as datetime for user.<br/>Will be customizable in future but at present chooses the ISO format.

Examples
--------
```tcl

% format_timestamp now
2007-11-05 17:30:14
%
% format_timestamp &quot;23/5/2008 10:11:28&quot;
2008-05-23 10:11:28
%
% format_timestamp &quot;23rd June 2008 10:11&quot;
2008-06-23 10:11:00

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"