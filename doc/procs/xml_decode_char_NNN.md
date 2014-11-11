qc::xml_decode_char_NNN
=======================

part of [Docs](../index.md)

Usage
-----
`
        qc::xml_decode_char_NNN string
    `

Description
-----------
Convert entity decimal format to ascii character

Examples
--------
```tcl

% qc::xml_decode_char_NNN "&#167; and &#166; are special characters."
 § and ¦ are special characters.
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"