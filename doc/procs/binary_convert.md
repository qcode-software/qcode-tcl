qc::binary_convert
==================

part of [Docs](../index.md)

Usage
-----
`qc::binary_convert args`

Description
-----------
Convert binary file size units.<br/>Usage: qc::binary_convert size from_unit to_unit<br/>qc::binary_convert size to_unit

Examples
--------
```tcl

% qc::binary_convert 2048 KB MB
2.0
% qc::binary_convert "3072MB" GB
3.0
% qc::binary_convert "3 GB" kilobyte
3145728.0
    % qc::binary_convert "3 GibiByte" KibiB
3145728.0

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"