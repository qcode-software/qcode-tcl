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
&lt;select id=&quot;price_op&quot; name=&quot;price_op&quot;&gt;
&lt;option value=&quot;&amp;gt;&quot;&gt;greater than&lt;/option&gt;
&lt;option value=&quot;=&quot; selected&gt;equals&lt;/option&gt;
&lt;option value=&quot;&amp;lt;&quot;&gt;less than&lt;/option&gt;
&lt;/select&gt;
&lt;input style=&quot;width:160px&quot; id=&quot;price&quot; value=&quot;10&quot; name=&quot;price&quot; type=&quot;text&quot;&gt;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"