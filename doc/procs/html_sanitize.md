qc::html_sanitize
===========

part of [Safe HTML](../safe-html-markdown.md)

Usage
-----
`html_sanitize text`

Description
-----------
Sanitizes the given text by removing any html and attributes that are not whitelisted.

Examples
--------
```tcl

% html_sanitize "<p>foo<p>"
<p>foo<p>

% html_sanitize "<p><script>alert('Foo');</script></p>"
<p></p>

% html_sanitize "<p foo=\"bar\">Foo</p>"
<p>Foo</p>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"