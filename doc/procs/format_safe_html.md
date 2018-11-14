qc::format_safe_html
===========

part of [Docs](../index.md)

Usage
-----
`format_safe_html safe_html`

Description
-----------
Formats the given text by removing <root> node if present and converting back to HTML from XML.

Examples
--------
```tcl

% format_safe_html "<root><p>Foo</p></root>"
<p>Foo</p>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"