qc::pkcs_padding_append
=======================

part of [Docs](.)

Usage
-----
`qc::pkcs_padding_append string`

Description
-----------
Pads out the string to be multiple of 8 bytes in length.<br/>Padding character as per PKCS (RFC 2898).

Examples
--------
```tcl

% set pkcs_padding_append &quot;Hello World&quot;
Hello World\5\5\5\5\5

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"