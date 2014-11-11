qc::dict2xml
============

part of [Docs](.)

Usage
-----
`qc::dict2xml dict`

Description
-----------
Convert top level {key value} pairs in dict value to xml elements.<br/>Return xml.

Examples
--------
```tcl

% set dict {a 1 b 2 c 3}
a 1 b 2 c 3

% qc::dict2xml $dict
&lt;a&gt;1&lt;/a&gt;
&lt;b&gt;2&lt;/b&gt;
&lt;c&gt;3&lt;/c&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"