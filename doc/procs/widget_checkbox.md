qc::widget_checkbox
===================

part of [Docs](.)

Usage
-----
`
	widget_checkbox name widgetName value Value ?id ID? 
    `

Description
-----------
Return an HTML form, checkbox input widget.<br>
    Sometimes used against a list of documents all using the same variable name. The POST is then interpreted as a list of say ID's that have been ticked.

Examples
--------
```tcl

% widget_checkbox name order_no value 3215
<input id="order_no" value="3215" name="order_no" type="checkbox">


```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"