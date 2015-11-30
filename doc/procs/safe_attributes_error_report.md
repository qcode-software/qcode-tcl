qc::safe_attributes_error_report
===========

part of [Safe HTML](../safe-html-markdown.md)

Usage
-----
`safe_attributes_error_report node`

Description
-----------
Checks the tdom node and all of it's children for unsafe html attributes and values.

Returns a list of dictionaries that specify unsafe attributes.

See [`safe_html_error_report`] for a breakdown of the returned dictionaries.

Examples
--------
```tcl

% set doc [dom parse -html "<p foo=\"Bar\">Hello World!</p>"]
domDoc0xc64b80

% set root [$doc documentElement]
domNode0xb3ac30

% safe_attributes_error_report $root
{node_value {<p foo="Bar">Hello World!</p>} element p attribute foo reason {Unsafe attribute: foo}}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[`safe_html_error_report`]: safe_html_error_report.md