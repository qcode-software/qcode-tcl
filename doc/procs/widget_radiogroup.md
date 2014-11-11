qc::widget_radiogroup
=====================

part of [Docs](.)

Usage
-----
`
	widget_radiogroup name widgetName value checkedValue options {name value name value ...} ?..?
    `

Description
-----------
Return an HTML form, radio button group

Examples
--------
```tcl

widget_radiogroup name sex value M options {Male M Female F}
<div class="radio-group" name="sex" id="sex">
<input id="sexM" value="M" name="sex" type="radio" checked>&nbsp;<label for="sexM">Male</label>
&nbsp; &nbsp;
<input id="sexF" value="F" name="sex" type="radio">&nbsp;<label for="sexF">Female</label>
</div>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"