qc::safe_elements_error_report
===========

part of [Safe HTML](../safe-html-markdown.md)

Usage
-----
`safe_elements_error_report node`

Description
-----------
Checks the tdom node and all of it's children for unsafe html elements.

Returns a list of dictionaries that specify unsafe elements.

See [`safe_html_error_report`] for a breakdown of the returned dictionaries.

Examples
--------
```tcl

% set doc [dom parse -html "<p><script>alert('Foo');</script></p>"]
domDoc0xc64b80

% set root [$doc documentElement]
domNode0xb3ac30

% safe_elements_error_report $root
{node_value {<script>alert('Foo');</script>} element script reason {Unsafe element: script}}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[`safe_html_error_report`]: safe_html_error_report.md