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
&lt;div class=&quot;radio-group&quot; name=&quot;sex&quot; id=&quot;sex&quot;&gt;
&lt;input id=&quot;sexM&quot; value=&quot;M&quot; name=&quot;sex&quot; type=&quot;radio&quot; checked&gt;&amp;nbsp;&lt;label for=&quot;sexM&quot;&gt;Male&lt;/label&gt;
&amp;nbsp; &amp;nbsp;
&lt;input id=&quot;sexF&quot; value=&quot;F&quot; name=&quot;sex&quot; type=&quot;radio&quot;&gt;&amp;nbsp;&lt;label for=&quot;sexF&quot;&gt;Female&lt;/label&gt;
&lt;/div&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"