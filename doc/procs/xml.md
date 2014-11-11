qc::xml
=======

part of [Docs](.)

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

% qc::xml message &quot;This is the message&quot; [dict create messageType text]
&lt;message messageType=&quot;text&quot;&gt;This is the message&lt;/message&gt;
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"