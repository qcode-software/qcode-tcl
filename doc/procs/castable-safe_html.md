qc::castable safe_html
==============

part of [Castable API](../castable.md)

Usage
-----
`qc::castable safe_html text`

Description
-----------
Test if the given text can be cast to safe html.

Examples
--------
```tcl

% qc::castable safe_html {Hello <a href="http://www.google.co.uk">World</a>}
1
% qc::castable safe_html {<script>alert('Foo')</script>}
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"