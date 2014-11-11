qc::widget_htmlarea
===================

part of [Docs](.)

Usage
-----
`
	widget_htmlarea name widgetName value html ?width size? ?height size? ?..?
    `

Description
-----------
Return an HTML form htmlarea widget made from an editable div tag.

Examples
--------
```tcl

% widget_htmlarea name notes value "A <i>little</i> note."
<div contentEditable="true" id="notes" style="width:160px;height:100px" value="A &lt;i&gt;little&lt;/i&gt; note." name="notes" class="db-form-html-area">A <i>little</i> note.</div>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"