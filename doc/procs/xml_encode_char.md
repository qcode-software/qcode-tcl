qc::xml_encode_char
===================

part of [Docs](.)

Usage
-----
`
        qc::xml_encode_char string
    `

Description
-----------
Convert character to entity decimal format.

Examples
--------
```tcl

% qc::xml_encode_char a
&#97;
% qc::xml_encode_char \u009F
&#159;
% qc::xml_encode_char !
&#33;
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"