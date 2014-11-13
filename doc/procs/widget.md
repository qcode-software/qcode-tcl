qc::widget
==========

part of [Docs](../index.md)

Usage
-----
`
	widget name widgetName label labelText ?required yes?
    `

Description
-----------
Look for a proc "widget_$type" to make the widget

Examples
--------
```tcl

% qc::widget type text name textWidget value "Horses" tooltip "This is a tooltip"
<input style="width:160px" id="textWidget" value="Horses" name="textWidget" type="text" title="This is a tooltip">

% qc::widget type label name labelWidget label "This is a label" tooltip "This is a tooltip"
<label for="labelWidget" title="This is a tooltip">This is a label</label>

% qc::widget type quantum name quantumWidget value "Everything" 
No widget proc defined for quantum
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"