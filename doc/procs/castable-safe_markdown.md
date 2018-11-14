qc::castable safe_markdown
==============

part of [Castable API](../castable.md)

Usage
-----
`qc::castable safe_markdown text`

Description
-----------
Test if the given text can be cast to safe markdown.

Examples
--------
```tcl

% qc::castable safe_markdown {# Hello `World`}
1
% qc::castable safe_markdown {<script>alert('Foo')</script>}
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"