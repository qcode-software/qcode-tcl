qc::widget_compare
==================

part of [Docs](.)

Usage
-----
`
	widget_compare name widgetName value Value ?operator Operator? ?...?
    `

Description
-----------
Return an HTML form widget with an operator drop down and input box.

Examples
--------
```tcl

% widget_compare name price value 10 operator =
widget_compare name price value 10 operator =
<select id="price_op" name="price_op">
<option value="&gt;">greater than</option>
<option value="=" selected>equals</option>
<option value="&lt;">less than</option>
</select>
<input style="width:160px" id="price" value="10" name="price" type="text">

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"