qc::widget_textarea
===================

part of [Docs](.)

Usage
-----
`
	widget_textarea name widgetName value text ?width size? ?height size? ?..?
    `

Description
-----------
Return an HTML form textarea element.

Examples
--------
```tcl

% widget_textarea name notes value &quot;Hi There&quot;
    &lt;div contentEditable=&quot;true&quot; id=&quot;notes&quot; style=&quot;width:160px;height:100px&quot; value=&quot;Hi There&quot; name=&quot;notes&quot;&gt;Hi There&lt;/div&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"