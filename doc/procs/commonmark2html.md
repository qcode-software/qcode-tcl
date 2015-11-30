qc::commonmark2html
===========

part of [Safe Markdown](../safe-html-markdown.md)

Usage
-----
`commonmark2html ?-unsafe? ?--? text`

Description
-----------
Converts Commonmark Markdown (http://commonmark.org) to  HTML.

By default, `commonmark2html` will only accept [safe markdown]. If unsafe markdown is desired then the `-unsafe` flag should be used.

Examples
--------
```tcl

% commonmark2html "`Hello World`"
<p><code>Hello World</code></p>

% commonmark2html "`Hello World` <script>alert('Foo');</script>"
Markdown contains unsafe HTML.

% commonmark2html -unsafe "`Hello World` <script>alert('Foo');</script>"
<p><code>Hello World</code> <script>alert('Foo');</script></p>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[safe markdown]: ../safe-html-markdown.md