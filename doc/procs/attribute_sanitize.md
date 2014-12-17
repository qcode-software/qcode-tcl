qc::attribute_sanitize
===========

part of [Docs](../index.md)

Usage
-----
`attribute_sanitize node`

Description
-----------
Checks the node and all of it's children for safe attributes removing those that are unsafe.

Examples
--------
```tcl

% set doc [dom parse -html "<p foo=\"bar\">Hello world</p>"]
domDoc0x43046b0
% set root [$doc documentElement]
domNode0x377c310
%
% attribute_sanitize $root

% set html [$doc asHTML -escapeNonASCII -htmlEntities]
<p>Hello world</p>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"