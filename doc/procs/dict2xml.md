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
<a>1</a>
<b>2</b>
<c>3</c>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"