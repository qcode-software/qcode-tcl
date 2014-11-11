qc::xml
=======

part of [Docs](../index.md)

Usage
-----
`
        qc::xml tagName nodeValue ?{?attrib value? ?attrib value? ...}?
    `

Description
-----------
Constructs xml from supplies parameters.

Examples
--------
```tcl

% qc::xml message "This is the message" [dict create messageType text]
<message messageType="text">This is the message</message>
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"