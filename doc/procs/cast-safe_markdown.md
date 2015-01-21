qc::cast safe_markdown
==============

part of [Docs](../index.md)

Usage
-----
`qc::cast safe_markdown text`

Description
-----------
Cast text to safe_markdown.

See [Safe HTML] for more information regarding safe elements, attributes, and values.

Examples
--------
```tcl

% qc::cast safe_markdown "# Hello World"
# Hello World

% qc::cast safe_markdown {```tcl puts "Hello World"```}
```tcl puts "Hello World"```

% qc::cast safe_markdown {Foo <script>alert('Hello World');</script>}
Can't cast "Foo <script>alert('Hello World');</script>...": not safe markdown.
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[Safe HTML]: ../safe-html.md