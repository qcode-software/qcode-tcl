qc::is safe_markdown
==============

part of [Is API](../is.md)

Usage
-----
`qc::is safe_markdown markdown`

Description
-----------
Checks if the given markdown contains only safe HTML elements and attributes.

See [Safe HTML] for more information regarding safe elements, attributes, and values.

Examples
--------
```tcl

% qc::is safe_markdown {*markdown*}
1
% qc::is safe_html {A code example ```tcl puts "Hello World"```}
1
% qc::is safe_html {<div id="content">Foo</div>}
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[Safe HTML]: ../safe_html.md