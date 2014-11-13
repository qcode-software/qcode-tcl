qc::file_temp
=============

part of [Docs](../index.md)

Usage
-----
`qc::file_temp text ?mode?`

Description
-----------
Write the text $text out into a temporary file<br/>and return the name of the file.

Examples
--------
```tcl

% set csv {
    Jimmy,1
    Des,3
    Bob,6
}
% file_temp $csv
/tmp/ns.aCtGxR

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"