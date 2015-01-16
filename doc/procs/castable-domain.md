qc::castable domain
==============

part of [Docs](../index.md)

Usage
-----
`qc::castable domain name value`

Description
-----------
Test if the given value can be cast to domain $name.

Examples
--------
```tcl

% qc::castable domain plain_text "Hellow World"
true
% qc::castable domain plain_text "<div>Foo</div>"
false
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"