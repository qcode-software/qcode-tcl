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

% qc::xml_escape &quot;Special characters like \u009F and reserved characters like &lt; &gt; and &amp; are escaped&quot;
Special characters like &amp;#159; and reserved characters like &amp;lt; &amp;gt; and &amp;amp; are escaped
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"