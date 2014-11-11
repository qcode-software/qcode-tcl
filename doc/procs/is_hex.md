qc::is_hex
==========

part of [Docs](.)

Usage
-----
`qc::is_hex string`

Description
-----------
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