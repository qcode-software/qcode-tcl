qc::cast safe_html
==============

part of [Docs](../index.md)

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

% qc::cast safe_html "Hello World"
<root>Hello World</root>

% qc::cast safe_html {<div id="foo">Bar</div>}
<root>
    <div>Bar</div>
</root>

% qc::cast safe_html {Foo <script>alert('Hello World');</script>}
<root>Foo </root>
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[Safe HTML]: ../safe-html.md