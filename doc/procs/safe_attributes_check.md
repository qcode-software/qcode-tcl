qc::safe_attributes_check
===========

part of [Docs](../index.md)

Usage
-----
`safe_attributes_check node`

Description
-----------
Checks the node and all of it's children for unsafe attributes.
Returns true if all elements are safe otherwise false.

Examples
--------
```tcl

% set doc [dom parse -html "<p foo=\"bar\">Hello world</p>"]
domDoc0x43046b0
% set root [$doc documentElement]
domNode0x377c310
%
% safe_attributes_check $root
false

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"