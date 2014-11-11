qc::tson_object_from
====================

part of [Docs](.)

Usage
-----
`qc::tson_object_from args`

Description
-----------
Take a list of var names and return a tson object

Examples
--------
```tcl

% set foo Hello
Hello
% set bar "World's Apart"
World's Apart
% qc::tson_object_from foo bar
object foo {string Hello} bar {string {World's Apart}}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"