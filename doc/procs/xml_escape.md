qc::xml_escape
==============

part of [Docs](.)

Usage
-----
`
        qc::xml_escape string
    `

Description
-----------
Escape reserved characters and converts characters above 127 to entity decimal

Examples
--------
```tcl

% qc::xml_escape "Special characters like \u009F and reserved characters like < > and & are escaped"
Special characters like &#159; and reserved characters like &lt; &gt; and &amp; are escaped
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"