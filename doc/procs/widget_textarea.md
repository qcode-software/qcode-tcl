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

% widget_textarea name notes value "Hi There"
    <div contentEditable="true" id="notes" style="width:160px;height:100px" value="Hi There" name="notes">Hi There</div>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"