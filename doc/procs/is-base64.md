qc::is base64
=============

part of [Docs](../index.md)

Usage
-----
`qc::is base64 string`

Description
-----------
Checks if the given string has only allowable base64 characters and is of the correct format.

Examples
--------
```tcl

% qc::is base64 RG9sbHkgUGFydG9uCg==
1
% qc::is base64 RG9sbHkgUGFydG9uCg
0
% qc::is base64 RG9sbHkgUGFydG9uCg=
0
% qc::is base64 ^^RG9sbHkgUGFydG9uCg
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
