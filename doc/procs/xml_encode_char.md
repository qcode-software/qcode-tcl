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
&amp;#97;
% qc::xml_encode_char \u009F
&amp;#159;
% qc::xml_encode_char !
&amp;#33;
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"