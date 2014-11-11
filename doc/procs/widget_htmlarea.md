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

% widget_htmlarea name notes value &quot;A &lt;i&gt;little&lt;/i&gt; note.&quot;
&lt;div contentEditable=&quot;true&quot; id=&quot;notes&quot; style=&quot;width:160px;height:100px&quot; value=&quot;A &amp;lt;i&amp;gt;little&amp;lt;/i&amp;gt; note.&quot; name=&quot;notes&quot; class=&quot;db-form-html-area&quot;&gt;A &lt;i&gt;little&lt;/i&gt; note.&lt;/div&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"