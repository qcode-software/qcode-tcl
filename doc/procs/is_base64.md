qc::is_base64
=============

part of [Docs](.)

Usage
-----
`qc::is_base64 string`

Description
-----------
Checks input has only allowable base64 characters and is of the correct format

Examples
--------
```tcl

% qc::is_base64 RG9sbHkgUGFydG9uCg==
1
% qc::is_base64 RG9sbHkgUGFydG9uCg
0
% qc::is_base64 RG9sbHkgUGFydG9uCg=
0
% qc::is_base64 ^^RG9sbHkgUGFydG9uCg
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"