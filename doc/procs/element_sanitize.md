qc::element_sanitize
===========

part of [Docs](../index.md)

Usage
-----
`element_sanitize node`

Description
-----------
Checks the tdom node and all of it's children for safe html elements removing those that are unsafe.

Examples
--------
```tcl

% set doc [dom parse -html "<p>Hello world</p> <script>alert('foo');</script>"]
domDoc0x43046b0
% set root [$doc documentElement]
domNode0x377c310
%
% element_sanitize $root

% set html [$doc asHTML -escapeNonASCII -htmlEntities]
<p>Hello world</p>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"