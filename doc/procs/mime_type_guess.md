qc::mime_type_guess
===================

part of [Docs](../index.md)

Usage
-----
`qc::mime_type_guess filename`

Description
-----------
Lookup a mimetype based on a file extension. Case insensitive.

Examples
--------
```tcl

% qc::mime_type_guess foo.pdf
application/pdf
% qc::mime_type_guess crack.exe
application/octet-stream

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"