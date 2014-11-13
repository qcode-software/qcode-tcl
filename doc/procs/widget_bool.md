qc::widget_bool
===============

part of [Docs](../index.md)

Usage
-----
`
	widget_bool name widgetName value Value ?id ID? 
    `

Description
-----------
Return an HTML form, checkbox input widget.<br>
    The difference between widget_bool and widget_checkbox is that widget_bool always returns the value "true" if checked.<br>
    The checkbox is checked if the value passed to widget_bool is true.

Examples
--------
```tcl

% widget_bool name spam value no
<input boolean="true" id="spam" value="true" name="spam" type="checkbox">

% widget_bool name spam value yes
<input boolean="true" id="spam" value="true" name="spam" type="checkbox" checked>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"