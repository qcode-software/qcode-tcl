qc::is_hex
==========

part of [Docs](../index.md)

Usage
-----
`qc::is_hex string`

Description
-----------
Deprecated - see [qc::is hex]
Does the input look like a hex number?

Examples
--------
```tcl

%  qc::is_hex 9F
1
%  qc::is_hex 1a
1
%  qc::is_hex 9G
0
% qc::is_hex 9FFFFFF
1
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[qc::is hex]: is-hex.md