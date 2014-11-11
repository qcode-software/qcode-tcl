qc::widget_button
=================

part of [Docs](../index.md)

Usage
-----
`
	widget_button name widgetName value buttonText ?option value? ?..?
    `

Description
-----------
Return an HTML form, button

Examples
--------
```tcl

widget_button name foo value "Click Me" onclick "alert('Hi');"
<input id="foo" value="Click Me" name="foo" type="button" onclick="alert('Hi');">

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"