qc::safe_elements_check
===========

part of [Safe HTML](../safe-html-markdown.md)

Usage
-----
`safe_elements_check node`

Description
-----------
Checks the node and all of it's children for unsafe html elements.
Returns true if all elements are safe otherwise false.

Examples
--------
```tcl

% set doc [dom parse -html "<p>Hello world</p> <script>alert('foo');</script>"]
domDoc0x43046b0
% set root [$doc documentElement]
domNode0x377c310
%
% safe_elements_check $root
false

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"