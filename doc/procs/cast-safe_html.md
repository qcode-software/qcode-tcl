qc::cast safe_html
==============

part of [Cast API](../cast.md)

Usage
-----
`qc::cast safe_html text`

Description
-----------
Cast text to safe_html.

See [Safe HTML] for more information regarding safe elements, attributes, and values.

Examples
--------
```tcl

% qc::cast safe_html {<a href="http://www.qcode.co.uk">Hello World</a>}
<a href="http://www.qcode.co.uk">Hello World</a>

% qc::cast safe_html {<div id="foo">Bar</div>}
Can't cast "<div id="foo">Bar</div>...": not safe html.

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[Safe HTML]: ../safe-html.md